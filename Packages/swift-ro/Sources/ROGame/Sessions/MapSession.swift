//
//  MapSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import Combine
import Foundation
import RONetwork

final public class MapSession: SessionProtocol, @unchecked Sendable {
    public private(set) var account: AccountInfo
    public let char: CharInfo

    let client: Client
    let eventSubject = PassthroughSubject<any Event, Never>()

    var player = Player()
    var pendingNPCDialog: NPCDialog?

    private var timerSubscription: AnyCancellable?

    public var eventPublisher: AnyPublisher<any Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public init(account: AccountInfo, char: CharInfo, mapServer: MapServerInfo) {
        self.account = account
        self.char = char
        self.client = Client(name: "Map", address: mapServer.ip, port: mapServer.port)
    }

    public func start() {
        var subscription = ClientSubscription()

        subscription.subscribe(to: ClientError.self) { [unowned self] error in
            let event = ConnectionEvents.ErrorOccurred(error: error)
            self.eventSubject.send(event)
        }

        // See `clif_friendslist_send`
        subscription.subscribe(to: PACKET_ZC_FRIENDS_LIST.self) { packet in
        }

        // 0x283
        subscription.subscribe(to: PACKET_ZC_AID.self) { [unowned self] packet in
            self.account.accountID = packet.accountID
        }

        // See `clif_hotkeys_send`
        subscription.subscribe(to: PACKET_ZC_SHORTCUT_KEY_LIST.self) { packet in
        }

        // See `clif_inventory_expansion_info`
        subscription.subscribe(to: PACKET_ZC_EXTEND_BODYITEM_SIZE.self) { packet in
        }

        // See `clif_ping`
        subscription.subscribe(to: PACKET_ZC_PING_LIVE.self) { [unowned self] packet in
            var packet = PACKET_CZ_PING_LIVE()
            packet.packetType = HEADER_CZ_PING_LIVE

            self.client.sendPacket(packet)
        }

        subscribeToMapConnectionPackets(with: &subscription)
        subscribeToMapPackets(with: &subscription)
        subscribeToPlayerPackets(with: &subscription)
        subscribeToAchievementPackets(with: &subscription)
        subscribeToInventoryPackets(with: &subscription)
        subscribeToMailPackets(with: &subscription)
        subscribeToRodexPackets(with: &subscription)
        subscribeToNPCPackets(with: &subscription)
        subscribeToMapItemPackets(with: &subscription)
        subscribeToMapObjectPackets(with: &subscription)
        subscribeToPartyPackets(with: &subscription)

        // See `clif_reputation_list`
        subscription.subscribe(to: PACKET_ZC_REPUTE_INFO.self) { packet in
        }

        // See `clif_broadcast2`
        subscription.subscribe(to: PACKET_ZC_BROADCAST2.self) { packet in
        }

        // See `clif_authfail_fd`
        subscription.subscribe(to: PACKET_SC_NOTIFY_BAN.self) { [unowned self] packet in
            let event = AuthenticationEvents.Banned(packet: packet)
            self.postEvent(event)
        }

        client.connect(with: subscription)

        enter()

        keepAlive()
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
    private func enter() {
        var packet = PACKET_CZ_ENTER()
        packet.accountID = account.accountID
        packet.charID = char.charID
        packet.loginID1 = account.loginID1
        packet.clientTime = UInt32(Date.now.timeIntervalSince1970)
        packet.sex = account.sex

        client.sendPacket(packet)

        if PACKET_VERSION < 20070521 {
            client.receiveDataAndPacket(count: 4) { data in
                let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
                self.account.accountID = accountID
            }
        } else {
            client.receivePacket()
        }
    }

    private func subscribeToMapConnectionPackets(with subscription: inout ClientSubscription) {
        // See `clif_authok`
        subscription.subscribe(to: PACKET_ZC_ACCEPT_ENTER.self) { [unowned self] packet in
            let event = MapConnectionEvents.Accepted()
            self.postEvent(event)
        }
    }

    private func subscribeToMapPackets(with subscription: inout ClientSubscription) {
        // See `clif_changemap`
        subscription.subscribe(to: PACKET_ZC_NPCACK_MAPMOVE.self) { [unowned self] packet in
            let position = SIMD2(Int16(packet.xPos), Int16(packet.yPos))
            self.player.position = position

            let event = MapEvents.Changed(mapName: packet.mapName, position: position)
            self.postEvent(event)
        }
    }

    private func subscribeToAchievementPackets(with subscription: inout ClientSubscription) {
        // 0xa23
        subscription.subscribe(to: PACKET_ZC_ALL_ACH_LIST.self) { [unowned self] packet in
            let event = AchievementEvents.Listed()
            self.postEvent(event)
        }

        // 0xa24
        subscription.subscribe(to: PACKET_ZC_ACH_UPDATE.self) { [unowned self] packet in
            let event = AchievementEvents.Updated()
            self.postEvent(event)
        }
    }

    private func subscribeToInventoryPackets(with subscription: inout ClientSubscription) {
        // See `clif_inventoryStart`
        subscription.subscribe(to: PACKET_ZC_INVENTORY_START.self) { packet in
        }

        // See `clif_inventorylist`
        subscription.subscribe(to: packet_itemlist_normal.self) { packet in
        }

        // See `clif_inventorylist`
        subscription.subscribe(to: packet_itemlist_equip.self) { packet in
        }

        // See `clif_inventoryEnd`
        subscription.subscribe(to: PACKET_ZC_INVENTORY_END.self) { packet in
        }

        // See `clif_additem`
        subscription.subscribe(to: PACKET_ZC_ITEM_PICKUP_ACK.self) { packet in
        }

        // See `clif_dropitem`
        subscription.subscribe(to: PACKET_ZC_ITEM_THROW_ACK.self) { packet in
        }
    }

    private func subscribeToMapObjectPackets(with subscription: inout ClientSubscription) {
        // See `clif_spawn_unit`
        subscription.subscribe(to: packet_spawn_unit.self) { [unowned self] packet in
            let object = MapObject(packet: packet)
            let event = MapObjectEvents.Spawned(object: object)
            self.postEvent(event)
        }

        // See `clif_set_unit_idle`
        subscription.subscribe(to: packet_idle_unit.self) { [unowned self] packet in
            let object = MapObject(packet: packet)
            let event = MapObjectEvents.Spawned(object: object)
            self.postEvent(event)
        }

        // See `clif_set_unit_walking`
        subscription.subscribe(to: packet_unit_walking.self) { [unowned self] packet in
            let object = MapObject(packet: packet)

            let moveData = MoveData(data: packet.MoveData)
            let fromPosition = SIMD2(moveData.x0, moveData.y0)
            let toPosition = SIMD2(moveData.x1, moveData.y1)

            let event = MapObjectEvents.Moved(object: object, fromPosition: fromPosition, toPosition: toPosition)
            self.postEvent(event)
        }

        // See `clif_fixpos`
        subscription.subscribe(to: PACKET_ZC_STOPMOVE.self) { [unowned self] packet in
            let objectID = packet.AID
            let position: SIMD2<Int16> = [Int16(packet.xPos), Int16(packet.yPos)]
            let event = MapObjectEvents.Stopped(objectID: objectID, position: position)
            self.postEvent(event)
        }

        // See `clif_clearunit_single` and `clif_clearunit_area`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_VANISH.self) { [unowned self] packet in
            let objectID = packet.gid
            let event = MapObjectEvents.Vanished(objectID: objectID)
            self.postEvent(event)
        }

        // See `clif_changed_dir`
        subscription.subscribe(to: PACKET_ZC_CHANGE_DIRECTION.self) { [unowned self] packet in
            let event = MapObjectEvents.DirectionChanged(packet: packet)
            self.postEvent(event)
        }

        // See `clif_sprite_change`
        subscription.subscribe(to: PACKET_ZC_SPRITE_CHANGE.self) { [unowned self] packet in
            let event = MapObjectEvents.SpriteChanged(objectID: packet.AID)
            self.postEvent(event)
        }

        // See `clif_changeoption_target`
        subscription.subscribe(to: PACKET_ZC_STATE_CHANGE.self) { [unowned self] packet in
            let event = MapObjectEvents.StateChanged(packet: packet)
            self.postEvent(event)
        }

        // See `clif_damage` and `clif_takeitem` and `clif_sitting` and `clif_standing`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_ACT.self) { [unowned self] packet in
            let event = MapObjectEvents.ActionPerformed(packet: packet)
            self.postEvent(event)
        }

        // See `clif_skill_nodamage`
        subscription.subscribe(to: PACKET_ZC_USE_SKILL.self) { [unowned self] packet in
        }

        // See `clif_channel_msg` and `clif_messagecolor_target`
        subscription.subscribe(to: PACKET_ZC_NPC_CHAT.self) { [unowned self] packet in
            let event = MapObjectEvents.MessageReceived(message: packet.message)
            self.postEvent(event)
        }
    }

    private func subscribeToPartyPackets(with subscription: inout ClientSubscription) {
        // See `clif_partyinvitationstate`
        subscription.subscribe(to: PACKET_ZC_PARTY_CONFIG.self) { packet in
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

    func postEvent(_ event: some Event) {
        eventSubject.send(event)
    }
}
