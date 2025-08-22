//
//  MapSession.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import AsyncAlgorithms
import Combine
import Foundation
import ROConstants
import ROPackets

final public class MapSession: SessionProtocol, @unchecked Sendable {
    public private(set) var account: AccountInfo
    public let char: CharInfo

    let client: Client
    let eventSubject = PassthroughSubject<any Event, Never>()

    var status = CharacterStatus()
    var inventory = Inventory()
    var pendingNPCDialog: NPCDialog?

    private var timerTask: Task<Void, Never>?

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
            self.account.update(accountID: packet.accountID)
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
        subscribeToMailPackets(with: &subscription)
        subscribeToRodexPackets(with: &subscription)
        subscribeToNPCPackets(with: &subscription)
        subscribeToItemPackets(with: &subscription)
        subscribeToMapObjectPackets(with: &subscription)
        subscribeToPartyPackets(with: &subscription)
        subscribeToChatPackets(with: &subscription)

        // See `clif_reputation_list`
        subscription.subscribe(to: PACKET_ZC_REPUTE_INFO.self) { packet in
        }

        // See `clif_broadcast`
        subscription.subscribe(to: PACKET_ZC_BROADCAST.self) { packet in
        }

        // See `clif_broadcast2`
        subscription.subscribe(to: PACKET_ZC_BROADCAST2.self) { packet in
        }

        // See `clif_authfail_fd`
        subscription.subscribe(to: PACKET_SC_NOTIFY_BAN.self) { [unowned self] packet in
            let message = BannedMessage(packet: packet)
            let event = AuthenticationEvents.Banned(message: message)
            self.postEvent(event)
        }

        client.connect(with: subscription)

        enter()

        keepAlive()
    }

    public func stop() {
        client.disconnect()

        timerTask?.cancel()
        timerTask = nil
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
                self.account.update(accountID: accountID)
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
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))
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

    private func subscribeToMapObjectPackets(with subscription: inout ClientSubscription) {
        // See `clif_spawn_unit`
        subscription.subscribe(to: packet_spawn_unit.self) { [unowned self] packet in
            let object = MapObject(packet: packet)

            let posDir = PosDir(data: packet.PosDir)
            let position = SIMD2(x: Int(posDir.x), y: Int(posDir.y))

            let event = MapObjectEvents.Spawned(object: object, position: position)
            self.postEvent(event)
        }

        // See `clif_set_unit_idle`
        subscription.subscribe(to: packet_idle_unit.self) { [unowned self] packet in
            let object = MapObject(packet: packet)

            let posDir = PosDir(data: packet.PosDir)
            let position = SIMD2(x: Int(posDir.x), y: Int(posDir.y))

            let event = MapObjectEvents.Spawned(object: object, position: position)
            self.postEvent(event)
        }

        // See `clif_set_unit_walking`
        subscription.subscribe(to: packet_unit_walking.self) { [unowned self] packet in
            let object = MapObject(packet: packet)

            let moveData = MoveData(data: packet.MoveData)
            let startPosition = SIMD2(x: Int(moveData.x0), y: Int(moveData.y0))
            let endPosition = SIMD2(x: Int(moveData.x1), y: Int(moveData.y1))

            let event = MapObjectEvents.Moved(object: object, startPosition: startPosition, endPosition: endPosition)
            self.postEvent(event)
        }

        // See `clif_fixpos`
        subscription.subscribe(to: PACKET_ZC_STOPMOVE.self) { [unowned self] packet in
            let objectID = packet.AID
            let position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))
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
            let event = MapObjectEvents.DirectionChanged(
                objectID: packet.srcId,
                headDirection: packet.headDir,
                direction: packet.dir
            )
            self.postEvent(event)
        }

        // See `clif_sprite_change`
        subscription.subscribe(to: PACKET_ZC_SPRITE_CHANGE.self) { [unowned self] packet in
            let event = MapObjectEvents.SpriteChanged(objectID: packet.AID)
            self.postEvent(event)
        }

        // See `clif_changeoption_target`
        subscription.subscribe(to: PACKET_ZC_STATE_CHANGE.self) { [unowned self] packet in
            let event = MapObjectEvents.StateChanged(
                objectID: packet.AID,
                bodyState: StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none,
                healthState: StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none,
                effectState: StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
            )
            self.postEvent(event)
        }

        // See `clif_damage` and `clif_takeitem` and `clif_sitting` and `clif_standing`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_ACT.self) { [unowned self] packet in
            let event = MapObjectEvents.ActionPerformed(
                sourceObjectID: UInt32(packet.srcID),
                targetObjectID: UInt32(packet.targetID),
                actionType: DamageType(rawValue: Int(packet.type)) ?? .normal
            )
            self.postEvent(event)
        }

        // See `clif_skill_nodamage`
        subscription.subscribe(to: PACKET_ZC_USE_SKILL.self) { [unowned self] packet in
        }
    }

    private func subscribeToPartyPackets(with subscription: inout ClientSubscription) {
        // See `clif_partyinvitationstate`
        subscription.subscribe(to: PACKET_ZC_PARTY_CONFIG.self) { packet in
        }
    }

    private func subscribeToChatPackets(with subscription: inout ClientSubscription) {
        // See `clif_GlobalMessage`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_CHAT.self) { [unowned self] packet in
            let event = ChatEvents.MessageReceived(
                type: .public,
                senderObjectID: packet.GID,
                content: packet.Message
            )
            self.postEvent(event)
        }

        // See `clif_wis_message`
        subscription.subscribe(to: PACKET_ZC_WHISPER.self) { [unowned self] packet in
            let event = ChatEvents.MessageReceived(
                type: .private,
                senderObjectID: packet.senderGID,
                senderName: packet.sender,
                content: packet.message
            )
            self.postEvent(event)
        }

        // See `clif_displaymessage`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_PLAYERCHAT.self) { [unowned self] packet in
            let event = ChatEvents.MessageReceived(
                type: .`self`,
                content: packet.Message
            )
            self.postEvent(event)
        }

        // See `clif_displaymessage` and `clif_channel_msg` and `clif_messagecolor_target`
        subscription.subscribe(to: PACKET_ZC_NPC_CHAT.self) { [unowned self] packet in
            let event = ChatEvents.MessageReceived(
                type: .channel,
                senderObjectID: packet.accountID,
                content: packet.message,
                color: packet.color
            )
            self.postEvent(event)
        }

        // See `clif_party_message`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_CHAT_PARTY.self) { [unowned self] packet in
            let event = ChatEvents.MessageReceived(
                type: .party,
                senderObjectID: UInt32(packet.AID),
                content: packet.chatMsg
            )
            self.postEvent(event)
        }

        // See `clif_guild_message`
        subscription.subscribe(to: PACKET_ZC_GUILD_CHAT.self) { [unowned self] packet in
            let event = ChatEvents.MessageReceived(
                type: .guild,
                content: packet.message
            )
            self.postEvent(event)
        }

        // See `clif_bg_message`
//        subscription.subscribe(to: ZC_BATTLEFIELD_CHAT) { packet in
//        }

        // See `clif_clan_message`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_CLAN_CHAT.self) { [unowned self] packet in
            let event = ChatEvents.MessageReceived(
                type: .clan,
                senderName: packet.MemberName,
                content: packet.Message
            )
            self.postEvent(event)
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_REQUEST_TIME`` every 10 seconds.
    private func keepAlive() {
        let timer = AsyncTimerSequence(interval: .seconds(10), clock: .continuous)

        let startTime = Date.now
        let client = client

        timerTask = Task {
            for await _ in timer {
                var packet = PACKET_CZ_REQUEST_TIME()
                packet.clientTime = UInt32(Date.now.timeIntervalSince(startTime))

                client.sendPacket(packet)
            }
        }
    }

    public func notifyMapLoaded() {
        let packet = PACKET_CZ_NOTIFY_ACTORINIT()

        client.sendPacket(packet)
    }

    public func sendMessage(_ message: String) {
        if message.hasPrefix("%") {
//            PACKET_CZ_REQUEST_CHAT_PARTY
        } else if message.hasPrefix("$") {
//            PACKET_CZ_GUILD_CHAT
        } else if message.hasPrefix("/cl") {
//            PACKET_CZ_CLAN_CHAT
        } else {
            var packet = PACKET_CZ_REQUEST_CHAT()
            packet.message = "\(char.name) : \(message)"

            client.sendPacket(packet)
        }
    }

    func postEvent(_ event: some Event) {
        eventSubject.send(event)
    }
}
