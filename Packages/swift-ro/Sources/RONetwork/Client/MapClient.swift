//
//  MapClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import Combine
import Foundation
import ROGenerated

final public class MapClient: ClientBase {
    public let state: ClientState

    private var timerSubscription: AnyCancellable?

    public init(state: ClientState, mapServer: MapServerInfo) {
        self.state = state

        super.init(port: mapServer.port)

        // See `clif_friendslist_send`
        registerPacket(PACKET_ZC_FRIENDS_LIST.self, for: HEADER_ZC_FRIENDS_LIST) { packet in
        }

        // 0x283
        registerPacket(PACKET_ZC_AID.self, for: PACKET_ZC_AID.packetType) { [unowned self] packet in
            self.state.accountID = packet.accountID
        }

        // See `clif_hotkeys_send`
        registerPacket(PACKET_ZC_SHORTCUT_KEY_LIST.self, for: HEADER_ZC_SHORTCUT_KEY_LIST) { packet in
        }

        // See `clif_inventory_expansion_info`
        registerPacket(PACKET_ZC_EXTEND_BODYITEM_SIZE.self, for: HEADER_ZC_EXTEND_BODYITEM_SIZE) { packet in
        }

        // See `clif_ping`
        registerPacket(PACKET_ZC_PING_LIVE.self, for: HEADER_ZC_PING_LIVE) { [unowned self] packet in
            let packet = PACKET_CZ_PING_LIVE()
            self.sendPacket(packet)
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
        registerPacket(PACKET_ZC_REPUTE_INFO.self, for: HEADER_ZC_REPUTE_INFO) { packet in
        }

        // See `clif_broadcast2`
        registerPacket(PACKET_ZC_BROADCAST2.self, for: HEADER_ZC_BROADCAST2) { packet in
        }
    }

    private func registerMapConnectionPackets() {
        // See `clif_authok`
        registerPacket(PACKET_ZC_ACCEPT_ENTER.self, for: HEADER_ZC_ACCEPT_ENTER) { [unowned self] packet in
            let event = MapConnectionEvents.Accepted()
            self.postEvent(event)
        }
    }

    private func registerMapPackets() {
        // See `clif_changemap`
        registerPacket(PACKET_ZC_NPCACK_MAPMOVE.self, for: HEADER_ZC_NPCACK_MAPMOVE) { [unowned self] packet in
            let event = MapEvents.Changed(mapName: packet.mapName, position: [Int16(packet.xPos), Int16(packet.yPos)])
            self.postEvent(event)
        }
    }

    private func registerPlayerPackets() {
        // See `clif_walkok`
        registerPacket(PACKET_ZC_NOTIFY_PLAYERMOVE.self, for: HEADER_ZC_NOTIFY_PLAYERMOVE) { [unowned self] packet in
            let moveData = MoveData(data: packet.moveData)
            let event = PlayerEvents.Moved(moveData: moveData)
            self.postEvent(event)
        }

        // 0x8e
        registerPacket(PACKET_ZC_NOTIFY_PLAYERCHAT.self, for: PACKET_ZC_NOTIFY_PLAYERCHAT.packetType) { [unowned self] packet in
            let event = PlayerEvents.MessageDisplay(message: packet.message)
            self.postEvent(event)
        }
    }

    private func registerAchievementPackets() {
        // 0xa23
        registerPacket(PACKET_ZC_ALL_ACH_LIST.self, for: PACKET_ZC_ALL_ACH_LIST.packetType) { [unowned self] packet in
            let event = AchievementEvents.Listed()
            self.postEvent(event)
        }

        // 0xa24
        registerPacket(PACKET_ZC_ACH_UPDATE.self, for: PACKET_ZC_ACH_UPDATE.packetType) { [unowned self] packet in
            let event = AchievementEvents.Updated()
            self.postEvent(event)
        }
    }

    private func registerInventoryPackets() {
        // See `clif_inventoryStart`
        registerPacket(PACKET_ZC_INVENTORY_START.self, for: HEADER_ZC_INVENTORY_START) { packet in
        }

        // See `clif_inventorylist`
        registerPacket(packet_itemlist_normal.self, for: packet_header_inventorylistnormalType) { packet in
        }

        // See `clif_inventorylist`
        registerPacket(packet_itemlist_equip.self, for: packet_header_inventorylistequipType) { packet in
        }

        // See `clif_inventoryEnd`
        registerPacket(PACKET_ZC_INVENTORY_END.self, for: HEADER_ZC_INVENTORY_END) { packet in
        }
    }

    private func registerMailPackets() {
        // 0x24a
        registerPacket(PACKET_ZC_MAIL_RECEIVE.self, for: PACKET_ZC_MAIL_RECEIVE.packetType) { packet in
        }

        // See `clif_Mail_new`
        registerPacket(PACKET_ZC_NOTIFY_UNREADMAIL.self, for: packet_header_rodexicon) { packet in
        }
    }

    private func registerObjectPackets() {
        // See `clif_spawn_unit`
        registerPacket(packet_spawn_unit.self, for: packet_header_spawn_unitType) { [unowned self] packet in
            let event = ObjectEvents.Spawned(packet: packet)
            self.postEvent(event)
        }

        // See `clif_set_unit_idle`
        registerPacket(packet_idle_unit.self, for: packet_header_idle_unitType) { [unowned self] packet in
            let event = ObjectEvents.Spawned(packet: packet)
            self.postEvent(event)
        }

        // See `clif_set_unit_walking`
        registerPacket(packet_unit_walking.self, for: packet_header_unit_walkingType) { [unowned self] packet in
            let moveData = MoveData(data: packet.MoveData)
            let event = ObjectEvents.Moved(id: packet.AID, moveData: moveData)
            self.postEvent(event)
        }

        // See `clif_clearunit_single` and `clif_clearunit_area`
        registerPacket(PACKET_ZC_NOTIFY_VANISH.self, for: HEADER_ZC_NOTIFY_VANISH) { [unowned self] packet in
            let event = ObjectEvents.Vanished(id: packet.gid)
            self.postEvent(event)
        }

        // See `clif_changed_dir`
        registerPacket(PACKET_ZC_CHANGE_DIRECTION.self, for: HEADER_ZC_CHANGE_DIRECTION) { [unowned self] packet in
            let event = ObjectEvents.DirectionChanged(sourceID: packet.srcId, headDirection: packet.headDir, direction: packet.dir)
            self.postEvent(event)
        }

        // See `clif_sprite_change`
        registerPacket(PACKET_ZC_SPRITE_CHANGE.self, for: packet_header_sendLookType) { [unowned self] packet in
            let event = ObjectEvents.SpriteChanged(id: packet.AID)
            self.postEvent(event)
        }

        // See `clif_changeoption_target`
        registerPacket(PACKET_ZC_STATE_CHANGE.self, for: HEADER_ZC_STATE_CHANGE) { [unowned self] packet in
            let event = ObjectEvents.StateChanged(id: packet.AID)
            self.postEvent(event)
        }

        // See `clif_channel_msg` and `clif_messagecolor_target`
        registerPacket(PACKET_ZC_NPC_CHAT.self, for: HEADER_ZC_NPC_CHAT) { [unowned self] packet in
            let event = ObjectEvents.MessageDisplay(message: packet.message)
            self.postEvent(event)
        }
    }

    private func registerPartyPackets() {
        // See `clif_partyinvitationstate`
        registerPacket(PACKET_ZC_PARTY_CONFIG.self, for: HEADER_ZC_PARTY_CONFIG) { packet in
        }
    }

    private func registerStatusPackets() {
        // See `clif_par_change`
        registerPacket(PACKET_ZC_PAR_CHANGE.self, for: HEADER_ZC_PAR_CHANGE) { [unowned self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                let event = PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.count), value2: 0)
                self.postEvent(event)
            }
        }

        // See `clif_longpar_change`
        registerPacket(PACKET_ZC_LONGPAR_CHANGE.self, for: HEADER_ZC_LONGPAR_CHANGE) { [unowned self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                let event = PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.amount), value2: 0)
                self.postEvent(event)
            }
        }

        // See `clif_initialstatus`
        registerPacket(PACKET_ZC_STATUS.self, for: HEADER_ZC_STATUS) { packet in
        }

        // See `clif_zc_status_change`
        registerPacket(PACKET_ZC_STATUS_CHANGE.self, for: HEADER_ZC_STATUS_CHANGE) { [unowned self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.statusID)) {
                let event = PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.value), value2: 0)
                self.postEvent(event)
            }
        }

        // See `clif_cartcount`
        registerPacket(PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.self, for: HEADER_ZC_NOTIFY_CARTITEM_COUNTINFO) { packet in
        }

        // See `clif_attackrange`
        registerPacket(PACKET_ZC_ATTACK_RANGE.self, for: HEADER_ZC_ATTACK_RANGE) { [unowned self] packet in
            let event = PlayerEvents.AttackRangeChanged(value: Int(packet.currentAttRange))
            self.postEvent(event)
        }

        // See `clif_couplestatus`
        registerPacket(PACKET_ZC_COUPLESTATUS.self, for: HEADER_ZC_COUPLESTATUS) { [unowned self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.statusType)) {
                let event = PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.defaultStatus), value2: Int(packet.plusStatus))
                self.postEvent(event)
            }
        }

        // See `clif_longlongpar_change`
        registerPacket(PACKET_ZC_LONGLONGPAR_CHANGE.self, for: HEADER_ZC_LONGLONGPAR_CHANGE) { [unowned self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                let event = PlayerEvents.StatusPropertyChanged(sp: sp, value: Int(packet.amount), value2: 0)
                self.postEvent(event)
            }
        }
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

        sendPacket(packet)

        if PACKET_VERSION < 20070521 {
            receiveData { data in
                self.state.accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })

                self.receivePacket()
            }
        } else {
            receivePacket()
        }
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_REQUEST_TIME`` every 10 seconds.
    public func keepAlive() {
        let startTime = Date.now

        timerSubscription = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                var packet = PACKET_CZ_REQUEST_TIME()
                packet.clientTime = UInt32(Date.now.timeIntervalSince(startTime))

                self?.sendPacket(packet)
            }
    }

    public func notifyMapLoaded() {
        let packet = PACKET_CZ_NOTIFY_ACTORINIT()

        sendPacket(packet)
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

        sendPacket(packet)
    }

    /// Request action.
    ///
    /// Send ``PACKET_CZ_REQUEST_ACT``
    public func requestAction(action: UInt8) {
        var packet = PACKET_CZ_REQUEST_ACT()
        packet.action = action

        sendPacket(packet)
    }

    /// Request move.
    ///
    /// Send ``PACKET_CZ_REQUEST_MOVE``
    public func requestMove(x: Int16, y: Int16) {
        var packet = PACKET_CZ_REQUEST_MOVE()
        packet.x = x
        packet.y = y

        sendPacket(packet)
    }
}
