//
//  MapSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import Combine
import Foundation
import ROGenerated

final public class MapSession: SessionProtocol {
    let storage: SessionStorage

    let client: Client
    let eventSubject = PassthroughSubject<any Event, Never>()

    private var timerSubscription: AnyCancellable?

    public var eventPublisher: AnyPublisher<any Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public init(storage: SessionStorage, mapServer: MapServerInfo) {
        self.storage = storage

        self.client = Client(port: mapServer.port)

        client.errorHandler = { [unowned self] error in
            let event = ConnectionEvents.ErrorOccurred(error: error)
            self.eventSubject.send(event)
        }

        // See `clif_friendslist_send`
        client.registerPacket(PACKET_ZC_FRIENDS_LIST.self, for: HEADER_ZC_FRIENDS_LIST) { packet in
        }

        // 0x283
        client.registerPacket(PACKET_ZC_AID.self, for: PACKET_ZC_AID.packetType) { [unowned self] packet in
            Task {
                await self.storage.updateAccountID(packet.accountID)
            }
        }

        // See `clif_hotkeys_send`
        client.registerPacket(PACKET_ZC_SHORTCUT_KEY_LIST.self, for: HEADER_ZC_SHORTCUT_KEY_LIST) { packet in
        }

        // See `clif_inventory_expansion_info`
        client.registerPacket(PACKET_ZC_EXTEND_BODYITEM_SIZE.self, for: HEADER_ZC_EXTEND_BODYITEM_SIZE) { packet in
        }

        // See `clif_ping`
        client.registerPacket(PACKET_ZC_PING_LIVE.self, for: HEADER_ZC_PING_LIVE) { [unowned self] packet in
            let packet = PACKET_CZ_PING_LIVE()
            self.client.sendPacket(packet)
        }

        registerMapConnectionPackets()
        registerMapPackets()
        registerPlayerPackets()
        registerAchievementPackets()
        registerInventoryPackets()
        registerMailPackets()
        registerNPCPackets()
        registerObjectPackets()
        registerPartyPackets()
        registerStatusPackets()

        // See `clif_reputation_list`
        client.registerPacket(PACKET_ZC_REPUTE_INFO.self, for: HEADER_ZC_REPUTE_INFO) { packet in
        }

        // See `clif_broadcast2`
        client.registerPacket(PACKET_ZC_BROADCAST2.self, for: HEADER_ZC_BROADCAST2) { packet in
        }

        // See `clif_authfail_fd`
        client.registerPacket(PACKET_SC_NOTIFY_BAN.self, for: HEADER_SC_NOTIFY_BAN) { [unowned self] packet in
            let event = AuthenticationEvents.Banned(packet: packet)
            self.postEvent(event)
        }
    }

    private func registerMapConnectionPackets() {
        // See `clif_authok`
        client.registerPacket(PACKET_ZC_ACCEPT_ENTER.self, for: HEADER_ZC_ACCEPT_ENTER) { [unowned self] packet in
            let event = MapConnectionEvents.Accepted()
            self.postEvent(event)
        }
    }

    private func registerMapPackets() {
        // See `clif_changemap`
        client.registerPacket(PACKET_ZC_NPCACK_MAPMOVE.self, for: HEADER_ZC_NPCACK_MAPMOVE) { [unowned self] packet in
            Task {
                let position = SIMD2(Int16(packet.xPos), Int16(packet.yPos))

                await self.storage.updateMap(with: packet.mapName, position: position)

                let event = MapEvents.Changed(mapName: packet.mapName, position: position)
                self.postEvent(event)
            }
        }
    }

    private func registerPlayerPackets() {
        // See `clif_walkok`
        client.registerPacket(PACKET_ZC_NOTIFY_PLAYERMOVE.self, for: HEADER_ZC_NOTIFY_PLAYERMOVE) { [unowned self] packet in
            Task {
                let moveData = MoveData(data: packet.moveData)
                let fromPosition = SIMD2(moveData.x0, moveData.y0)
                let toPosition = SIMD2(moveData.x1, moveData.y1)

                await self.storage.updatePlayerPosition(toPosition)

                let event = PlayerEvents.Moved(fromPosition: fromPosition, toPosition: toPosition)
                self.postEvent(event)
            }
        }

        // 0x8e
        client.registerPacket(PACKET_ZC_NOTIFY_PLAYERCHAT.self, for: PACKET_ZC_NOTIFY_PLAYERCHAT.packetType) { [unowned self] packet in
            let event = PlayerEvents.MessageDisplay(packet: packet)
            self.postEvent(event)
        }
    }

    private func registerAchievementPackets() {
        // 0xa23
        client.registerPacket(PACKET_ZC_ALL_ACH_LIST.self, for: PACKET_ZC_ALL_ACH_LIST.packetType) { [unowned self] packet in
            let event = AchievementEvents.Listed()
            self.postEvent(event)
        }

        // 0xa24
        client.registerPacket(PACKET_ZC_ACH_UPDATE.self, for: PACKET_ZC_ACH_UPDATE.packetType) { [unowned self] packet in
            let event = AchievementEvents.Updated()
            self.postEvent(event)
        }
    }

    private func registerInventoryPackets() {
        // See `clif_inventoryStart`
        client.registerPacket(PACKET_ZC_INVENTORY_START.self, for: HEADER_ZC_INVENTORY_START) { packet in
        }

        // See `clif_inventorylist`
        client.registerPacket(packet_itemlist_normal.self, for: packet_header_inventorylistnormalType) { packet in
        }

        // See `clif_inventorylist`
        client.registerPacket(packet_itemlist_equip.self, for: packet_header_inventorylistequipType) { packet in
        }

        // See `clif_inventoryEnd`
        client.registerPacket(PACKET_ZC_INVENTORY_END.self, for: HEADER_ZC_INVENTORY_END) { packet in
        }
    }

    private func registerMailPackets() {
        // 0x24a
        client.registerPacket(PACKET_ZC_MAIL_RECEIVE.self, for: PACKET_ZC_MAIL_RECEIVE.packetType) { packet in
        }

        // See `clif_Mail_new`
        client.registerPacket(PACKET_ZC_NOTIFY_UNREADMAIL.self, for: packet_header_rodexicon) { packet in
        }
    }

    private func registerObjectPackets() {
        // See `clif_spawn_unit`
        client.registerPacket(packet_spawn_unit.self, for: packet_header_spawn_unitType) { [unowned self] packet in
            Task {
                let object = MapObject(packet: packet)

                await self.storage.updateMapObject(object)

                let event = MapObjectEvents.Spawned(object: object)
                self.postEvent(event)
            }
        }

        // See `clif_set_unit_idle`
        client.registerPacket(packet_idle_unit.self, for: packet_header_idle_unitType) { [unowned self] packet in
            Task {
                let object = MapObject(packet: packet)

                await self.storage.updateMapObject(object)

                let event = MapObjectEvents.Spawned(object: object)
                self.postEvent(event)
            }
        }

        // See `clif_set_unit_walking`
        client.registerPacket(packet_unit_walking.self, for: packet_header_unit_walkingType) { [unowned self] packet in
            Task {
                let object = MapObject(packet: packet)
                if let _ = await self.storage.updateMapObject(object) {
                    let moveData = MoveData(data: packet.MoveData)
                    let fromPosition = SIMD2(moveData.x0, moveData.y0)
                    let toPosition = SIMD2(moveData.x1, moveData.y1)

                    let event = MapObjectEvents.Moved(objectID: object.id, fromPosition: fromPosition, toPosition: toPosition)
                    self.postEvent(event)
                } else {
                    let event = MapObjectEvents.Spawned(object: object)
                    self.postEvent(event)
                }
            }
        }

        // See `clif_clearunit_single` and `clif_clearunit_area`
        client.registerPacket(PACKET_ZC_NOTIFY_VANISH.self, for: HEADER_ZC_NOTIFY_VANISH) { [unowned self] packet in
            Task {
                let objectID = packet.gid
                await self.storage.removeMapObject(for: objectID)

                let event = MapObjectEvents.Vanished(objectID: objectID)
                self.postEvent(event)
            }
        }

        // See `clif_changed_dir`
        client.registerPacket(PACKET_ZC_CHANGE_DIRECTION.self, for: HEADER_ZC_CHANGE_DIRECTION) { [unowned self] packet in
            let event = MapObjectEvents.DirectionChanged(packet: packet)
            self.postEvent(event)
        }

        // See `clif_sprite_change`
        client.registerPacket(PACKET_ZC_SPRITE_CHANGE.self, for: packet_header_sendLookType) { [unowned self] packet in
            let event = MapObjectEvents.SpriteChanged(objectID: packet.AID)
            self.postEvent(event)
        }

        // See `clif_changeoption_target`
        client.registerPacket(PACKET_ZC_STATE_CHANGE.self, for: HEADER_ZC_STATE_CHANGE) { [unowned self] packet in
            Task {
                if let object = await self.storage.updateMapObjectState(with: packet) {
                    let event = MapObjectEvents.StateChanged(
                        objectID: object.id,
                        bodyState: object.bodyState,
                        healthState: object.healthState,
                        effectState: object.effectState
                    )
                    self.postEvent(event)
                }
            }
        }

        // See `clif_channel_msg` and `clif_messagecolor_target`
        client.registerPacket(PACKET_ZC_NPC_CHAT.self, for: HEADER_ZC_NPC_CHAT) { [unowned self] packet in
            let event = MapObjectEvents.MessageDisplay(message: packet.message)
            self.postEvent(event)
        }
    }

    private func registerPartyPackets() {
        // See `clif_partyinvitationstate`
        client.registerPacket(PACKET_ZC_PARTY_CONFIG.self, for: HEADER_ZC_PARTY_CONFIG) { packet in
        }
    }

    private func registerStatusPackets() {
        // See `clif_par_change`
        client.registerPacket(PACKET_ZC_PAR_CHANGE.self, for: HEADER_ZC_PAR_CHANGE) { [unowned self] packet in
            if let event = PlayerEvents.StatusPropertyChanged(packet: packet) {
                self.postEvent(event)
            }
        }

        // See `clif_longpar_change`
        client.registerPacket(PACKET_ZC_LONGPAR_CHANGE.self, for: HEADER_ZC_LONGPAR_CHANGE) { [unowned self] packet in
            if let event = PlayerEvents.StatusPropertyChanged(packet: packet) {
                self.postEvent(event)
            }
        }

        // See `clif_initialstatus`
        client.registerPacket(PACKET_ZC_STATUS.self, for: HEADER_ZC_STATUS) { packet in
        }

        // See `clif_zc_status_change`
        client.registerPacket(PACKET_ZC_STATUS_CHANGE.self, for: HEADER_ZC_STATUS_CHANGE) { [unowned self] packet in
            if let event = PlayerEvents.StatusPropertyChanged(packet: packet) {
                self.postEvent(event)
            }
        }

        // See `clif_cartcount`
        client.registerPacket(PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.self, for: HEADER_ZC_NOTIFY_CARTITEM_COUNTINFO) { packet in
        }

        // See `clif_attackrange`
        client.registerPacket(PACKET_ZC_ATTACK_RANGE.self, for: HEADER_ZC_ATTACK_RANGE) { [unowned self] packet in
            let event = PlayerEvents.AttackRangeChanged(packet: packet)
            self.postEvent(event)
        }

        // See `clif_couplestatus`
        client.registerPacket(PACKET_ZC_COUPLESTATUS.self, for: HEADER_ZC_COUPLESTATUS) { [unowned self] packet in
            if let event = PlayerEvents.StatusPropertyChanged(packet: packet) {
                self.postEvent(event)
            }
        }

        // See `clif_longlongpar_change`
        client.registerPacket(PACKET_ZC_LONGLONGPAR_CHANGE.self, for: HEADER_ZC_LONGLONGPAR_CHANGE) { [unowned self] packet in
            if let event = PlayerEvents.StatusPropertyChanged(packet: packet) {
                self.postEvent(event)
            }
        }
    }

    func postEvent(_ event: some Event) {
        eventSubject.send(event)
    }

    public func start() {
        client.connect()

        Task {
            await enter()
            keepAlive()
        }
    }

    public func stop() {
        client.disconnect()

        timerSubscription = nil
    }

    /// Enter.
    ///
    /// Send ``PACKET_CZ_ENTER``
    ///
    /// Receive ``PACKET_ZC_AID`` +
    ///         ``PACKET_ZC_EXTEND_BODYITEM_SIZE`` +
    ///         ``PACKET_ZC_ACCEPT_ENTER``
    private func enter() async {
        var packet = PACKET_CZ_ENTER()
        packet.accountID = await storage.accountID
        packet.charID = await storage.charID
        packet.loginID1 = await storage.loginID1
        packet.clientTime = UInt32(Date.now.timeIntervalSince1970)
        packet.sex = await storage.sex

        client.sendPacket(packet)

        if PACKET_VERSION < 20070521 {
            client.receiveData { data in
                Task {
                    let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
                    await self.storage.updateAccountID(accountID)
                }

                self.client.receivePacket()
            }
        } else {
            client.receivePacket()
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_REQUEST_TIME`` every 10 seconds.
    private func keepAlive() {
        let startTime = Date.now

        timerSubscription = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                var packet = PACKET_CZ_REQUEST_TIME()
                packet.clientTime = UInt32(Date.now.timeIntervalSince(startTime))

                self?.client.sendPacket(packet)
            }
    }

    public func notifyMapLoaded() {
        let packet = PACKET_CZ_NOTIFY_ACTORINIT()

        client.sendPacket(packet)
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

        client.sendPacket(packet)
    }

    /// Request action.
    ///
    /// Send ``PACKET_CZ_REQUEST_ACT``
    public func requestAction(action: UInt8) {
        var packet = PACKET_CZ_REQUEST_ACT()
        packet.action = action

        client.sendPacket(packet)
    }

    /// Request move.
    ///
    /// Send ``PACKET_CZ_REQUEST_MOVE``
    public func requestMove(x: Int16, y: Int16) {
        var packet = PACKET_CZ_REQUEST_MOVE()
        packet.x = x
        packet.y = y

        client.sendPacket(packet)
    }
}
