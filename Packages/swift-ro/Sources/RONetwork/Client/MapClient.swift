//
//  MapClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import Combine
import Foundation
import ROGenerated

final public class MapClient {
    public let state: ClientState

    private let connection: ClientConnection

    private let eventSubject = PassthroughSubject<any Event, Never>()
    private var subscriptions = Set<AnyCancellable>()

    public init(state: ClientState, mapServer: MapServerInfo) {
        self.state = state

        connection = ClientConnection(port: mapServer.port)

        connection.errorHandler = { [weak self] error in
            let event = ConnectionEvents.ErrorOccurred(error: error)
            self?.eventSubject.send(event)
        }

        // See `clif_changed_dir`
        connection.registerPacket(PACKET_ZC_CHANGE_DIRECTION.self, for: HEADER_ZC_CHANGE_DIRECTION)
            .map { packet in
                BlockEvents.DirectionChanged(sourceID: packet.srcId, headDirection: packet.headDir, direction: packet.dir)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // See `clif_sprite_change`
        connection.registerPacket(PACKET_ZC_SPRITE_CHANGE.self, for: packet_header_sendLookType)

        // See `clif_friendslist_send`
        connection.registerPacket(PACKET_ZC_FRIENDS_LIST.self, for: HEADER_ZC_FRIENDS_LIST)

        // 0x283
        connection.registerPacket(PACKET_ZC_AID.self, for: PACKET_ZC_AID.packetType)
            .sink { [weak self] packet in
                self?.state.accountID = packet.accountID
            }
            .store(in: &subscriptions)

        // See `clif_hotkeys_send`
        connection.registerPacket(PACKET_ZC_SHORTCUT_KEY_LIST.self, for: HEADER_ZC_SHORTCUT_KEY_LIST)

        // See `clif_inventory_expansion_info`
        connection.registerPacket(PACKET_ZC_EXTEND_BODYITEM_SIZE.self, for: HEADER_ZC_EXTEND_BODYITEM_SIZE)

        // See `clif_ping`
        connection.registerPacket(PACKET_ZC_PING_LIVE.self, for: HEADER_ZC_PING_LIVE)
            .sink { [weak self] packet in
                let packet = PACKET_CZ_PING_LIVE()
                self?.connection.sendPacket(packet)
            }
            .store(in: &subscriptions)

        registerMapConnectionPackets()
        registerMapPackets()
        registerPlayerPackets()
        registerAchievementPackets()
        registerInventoryPackets()
        registerMailPackets()
        registerPartyPackets()
        registerStatusPackets()
    }

    private func registerMapConnectionPackets() {
        // See `clif_authok`
        connection.registerPacket(PACKET_ZC_ACCEPT_ENTER.self, for: HEADER_ZC_ACCEPT_ENTER)
            .map { packet in
                MapConnectionEvents.Accepted()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerMapPackets() {
        // See `clif_changemap`
        connection.registerPacket(PACKET_ZC_NPCACK_MAPMOVE.self, for: HEADER_ZC_NPCACK_MAPMOVE)
            .map { packet in
                MapEvents.Changed(mapName: packet.mapName, position: [packet.xPos, packet.yPos])
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerPlayerPackets() {
        // See `clif_walkok`
        connection.registerPacket(PACKET_ZC_NOTIFY_PLAYERMOVE.self, for: HEADER_ZC_NOTIFY_PLAYERMOVE)
            .map { packet in
                let moveData = MoveData(data: packet.moveData)
                let event = PlayerEvents.Moved(moveData: moveData)
                return event
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x8e
        connection.registerPacket(PACKET_ZC_NOTIFY_PLAYERCHAT.self, for: PACKET_ZC_NOTIFY_PLAYERCHAT.packetType)
            .map { packet in
                PlayerEvents.MessageDisplay(message: packet.message)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerAchievementPackets() {
        // 0xa23
        connection.registerPacket(PACKET_ZC_ALL_ACH_LIST.self, for: PACKET_ZC_ALL_ACH_LIST.packetType)
            .map { packet in
                AchievementEvents.Listed()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0xa24
        connection.registerPacket(PACKET_ZC_ACH_UPDATE.self, for: PACKET_ZC_ACH_UPDATE.packetType)
            .map { packet in
                AchievementEvents.Updated()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerInventoryPackets() {
        // See `clif_inventoryStart`
        connection.registerPacket(PACKET_ZC_INVENTORY_START.self, for: HEADER_ZC_INVENTORY_START)

        // See `clif_inventorylist`
        connection.registerPacket(packet_itemlist_normal.self, for: packet_header_inventorylistnormalType)

        // See `clif_inventorylist`
        connection.registerPacket(packet_itemlist_equip.self, for: packet_header_inventorylistequipType)

        // See `clif_inventoryEnd`
        connection.registerPacket(PACKET_ZC_INVENTORY_END.self, for: HEADER_ZC_INVENTORY_END)
    }

    private func registerMailPackets() {
        // 0x24a
        connection.registerPacket(PACKET_ZC_MAIL_RECEIVE.self, for: PACKET_ZC_MAIL_RECEIVE.packetType)

        // See `clif_Mail_new`
        connection.registerPacket(PACKET_ZC_NOTIFY_UNREADMAIL.self, for: packet_header_rodexicon)
    }

    private func registerPartyPackets() {
        // See `clif_partyinvitationstate`
        connection.registerPacket(PACKET_ZC_PARTY_CONFIG.self, for: HEADER_ZC_PARTY_CONFIG)
    }

    private func registerStatusPackets() {
        // See `clif_par_change`
        connection.registerPacket(PACKET_ZC_PAR_CHANGE.self, for: HEADER_ZC_PAR_CHANGE)
            .compactMap { packet in
                if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                    PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.count), value2: 0)
                } else {
                    nil
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // See `clif_longpar_change`
        connection.registerPacket(PACKET_ZC_LONGPAR_CHANGE.self, for: HEADER_ZC_LONGPAR_CHANGE)
            .compactMap { packet in
                if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                    PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.amount), value2: 0)
                } else {
                    nil
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // See `clif_initialstatus`
        connection.registerPacket(PACKET_ZC_STATUS.self, for: HEADER_ZC_STATUS)

        // See `clif_zc_status_change`
        connection.registerPacket(PACKET_ZC_STATUS_CHANGE.self, for: HEADER_ZC_STATUS_CHANGE)
            .compactMap { packet in
                if let sp = StatusProperty(rawValue: Int(packet.statusID)) {
                    PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.value), value2: 0)
                } else {
                    nil
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // See `clif_cartcount`
        connection.registerPacket(PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.self, for: HEADER_ZC_NOTIFY_CARTITEM_COUNTINFO)

        // See `clif_attackrange`
        connection.registerPacket(PACKET_ZC_ATTACK_RANGE.self, for: HEADER_ZC_ATTACK_RANGE)
            .map { packet in
                PlayerEvents.AttackRangeChanged(value: Int(packet.currentAttRange))
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // See `clif_couplestatus`
        connection.registerPacket(PACKET_ZC_COUPLESTATUS.self, for: HEADER_ZC_COUPLESTATUS)
            .compactMap { packet in
                if let sp = StatusProperty(rawValue: Int(packet.statusType)) {
                    PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.defaultStatus), value2: Int(packet.plusStatus))
                } else {
                    nil
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // See `clif_longlongpar_change`
        connection.registerPacket(PACKET_ZC_LONGLONGPAR_CHANGE.self, for: HEADER_ZC_LONGLONGPAR_CHANGE)
            .compactMap { packet in
                if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                    PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.amount), value2: 0)
                } else {
                    nil
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    public func subscribe<E>(to event: E.Type, _ handler: @escaping (E) -> Void) -> any Cancellable where E: Event {
        let cancellable = eventSubject
            .compactMap { event in
                event as? E
            }
            .sink { event in
                handler(event)
            }
        return cancellable
    }

    public func connect() {
        connection.start()
    }

    public func disconnect() {
        connection.cancel()
    }

    /// Enter.
    ///
    /// Send ``PACKET_CZ_ENTER``
    ///
    /// Receive ``PACKET_ZC_AID`` +
    ///         ``PACKET_ZC_EXTEND_BODYITEM_SIZE`` +
    ///         ``PACKET_ZC_ACCEPT_ENTER``
    public func enter() {
        var packet = PACKET_CZ_ENTER()
        packet.accountID = state.accountID
        packet.charID = state.charID
        packet.loginID1 = state.loginID1
        packet.clientTime = UInt32(Date.now.timeIntervalSince1970)
        packet.sex = state.sex

        connection.sendPacket(packet)

        if PACKET_VERSION < 20070521 {
            connection.receiveData { data in
                self.state.accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })

                self.connection.receivePacket()
            }
        } else {
            connection.receivePacket()
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_REQUEST_TIME`` every 10 seconds.
    public func keepAlive() {
        let startTime = Date.now

        Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                var packet = PACKET_CZ_REQUEST_TIME()
                packet.clientTime = UInt32(Date.now.timeIntervalSince(startTime))

                self?.connection.sendPacket(packet)
            }
            .store(in: &subscriptions)
    }

    public func notifyMapLoaded() {
        let packet = PACKET_CZ_NOTIFY_ACTORINIT()

        connection.sendPacket(packet)
    }

    /// Change direction.
    ///
    /// Send ``PACKET_CZ_CHANGE_DIRECTION``
    ///
    /// Receive ``PACKET_ZC_CHANGE_DIRECTION``
    public func changeDirection(headDirection: UInt16, direction: UInt8) {
        var packet = PACKET_CZ_CHANGE_DIRECTION()
        packet.headDirection = headDirection
        packet.direction = direction

        connection.sendPacket(packet)
    }

    /// Request action.
    ///
    /// Send ``PACKET_CZ_REQUEST_ACT``
    public func requestAction(action: UInt8) {
        var packet = PACKET_CZ_REQUEST_ACT()
        packet.action = action

        connection.sendPacket(packet)
    }

    /// Request move.
    ///
    /// Send ``PACKET_CZ_REQUEST_MOVE``
    public func requestMove(x: UInt16, y: UInt16) {
        var packet = PACKET_CZ_REQUEST_MOVE()
        packet.x = x
        packet.y = y

        connection.sendPacket(packet)
    }
}
