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

        // 0x9c
        connection.registerPacket(PACKET_ZC_CHANGE_DIRECTION.self)
            .map { packet in
                BlockEvents.DirectionChanged(sourceID: packet.sourceID, headDirection: packet.headDirection, direction: packet.direction)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0xc3, 0x1d7
        connection.registerPacket(PACKET_ZC_SPRITE_CHANGE.self)

        // 0x201
        connection.registerPacket(PACKET_ZC_FRIENDS_LIST.self)

        // 0x283
        connection.registerPacket(PACKET_ZC_AID.self)
            .sink { [weak self] packet in
                self?.state.accountID = packet.accountID
            }
            .store(in: &subscriptions)

        // 0x2b9, 0x7d9, 0xa00, 0xb20
        connection.registerPacket(PACKET_ZC_SHORTCUT_KEY_LIST.self)

        // 0xb18
        connection.registerPacket(PACKET_ZC_EXTEND_BODYITEM_SIZE.self)

        // 0xb1d
        connection.registerPacket(PACKET_ZC_PING_LIVE.self)
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
        // 0x73, 0x2eb, 0xa18
        connection.registerPacket(PACKET_ZC_ACCEPT_ENTER.self)
            .map { packet in
                MapConnectionEvents.Accepted()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerMapPackets() {
        // 0x91
        connection.registerPacket(PACKET_ZC_NPCACK_MAPMOVE.self)
            .map { packet in
                MapEvents.Changed(mapName: packet.mapName, position: [packet.x, packet.y])
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerPlayerPackets() {
        // 0x87
        connection.registerPacket(PACKET_ZC_NOTIFY_PLAYERMOVE.self)
            .map { packet in
                PlayerEvents.Moved(moveData: packet.moveData)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x8e
        connection.registerPacket(PACKET_ZC_NOTIFY_PLAYERCHAT.self)
            .map { packet in
                PlayerEvents.MessageDisplay(message: packet.message)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerAchievementPackets() {
        // 0xa23
        connection.registerPacket(PACKET_ZC_ALL_ACH_LIST.self)
            .map { packet in
                AchievementEvents.Listed()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0xa24
        connection.registerPacket(PACKET_ZC_ACH_UPDATE.self)
            .map { packet in
                AchievementEvents.Updated()
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    private func registerInventoryPackets() {
        // 0xb08
        connection.registerPacket(PACKET_ZC_INVENTORY_START.self)

        // 0xa3, 0x1ee, 0x2e8, 0x991, 0xb09
        connection.registerPacket(PACKET_ZC_ITEMLIST_NORMAL.self)

        // 0xa4, 0x295, 0x2d0, 0x992, 0xa0d, 0xb0a, 0xb39
        connection.registerPacket(PACKET_ZC_ITEMLIST_EQUIP.self)

        // 0xb0b
        connection.registerPacket(PACKET_ZC_INVENTORY_END.self)
    }

    private func registerMailPackets() {
        // 0x24a
        connection.registerPacket(PACKET_ZC_MAIL_RECEIVE.self)

        // 0x9e7
        connection.registerPacket(PACKET_ZC_NOTIFY_UNREADMAIL.self)
    }

    private func registerPartyPackets() {
        // 0x2c9
        connection.registerPacket(PACKET_ZC_PARTY_CONFIG.self)
    }

    private func registerStatusPackets() {
        // 0xb0
        connection.registerPacket(PACKET_ZC_PAR_CHANGE.self)
            .compactMap { packet in
                if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                    PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.count), value2: 0)
                } else {
                    nil
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0xb1
        connection.registerPacket(PACKET_ZC_LONGPAR_CHANGE.self)
            .compactMap { packet in
                if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                    PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.amount), value2: 0)
                } else {
                    nil
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0xbd
        connection.registerPacket(PACKET_ZC_STATUS.self)

        // 0xbe
        connection.registerPacket(PACKET_ZC_STATUS_CHANGE.self)
            .compactMap { packet in
                if let sp = StatusProperty(rawValue: Int(packet.statusID)) {
                    PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.value), value2: 0)
                } else {
                    nil
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x121
        connection.registerPacket(PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.self)

        // 0x13a
        connection.registerPacket(PACKET_ZC_ATTACK_RANGE.self)
            .map { packet in
                PlayerEvents.AttackRangeChanged(value: Int(packet.currentAttackRange))
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0x141
        connection.registerPacket(PACKET_ZC_COUPLESTATUS.self)
            .compactMap { packet in
                if let sp = StatusProperty(rawValue: Int(packet.statusType)) {
                    PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.defaultStatus), value2: Int(packet.plusStatus))
                } else {
                    nil
                }
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)

        // 0xacb
        connection.registerPacket(PACKET_ZC_LONGLONGPAR_CHANGE.self)
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
