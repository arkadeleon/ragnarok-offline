//
//  MapClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import Foundation

final public class MapClient {
    public let state: ClientState

    public var onAcceptEnter: (() -> Void)?

    public var onStatusPropertyChanged: ((_ sp: StatusProperty, _ value: Int, _ value2: Int) -> Void)?
    public var onAttackRangeChanged: ((_ attackRange: Int) -> Void)?

    public var onNotifyPlayerMove: ((_ moveData: MoveData) -> Void)?
    public var onChangeDirection: ((_ headDirection: UInt16, _ direction: UInt8) -> Void)?
    public var onError: ((_ error: any Error) -> Void)?

    private let connection: ClientConnection

    private var keepAliveTimer: Timer?

    public init(state: ClientState, mapServer: MapServerInfo) {
        self.state = state

        connection = ClientConnection(port: mapServer.port)

        connection.errorHandler = { [weak self] error in
            self?.onError?(error)
        }

        // 0x73, 0x2eb, 0xa18
        connection.registerPacket(PACKET_ZC_ACCEPT_ENTER.self) { [weak self] packet in
            self?.onAcceptEnter?()
        }

        // 0x87
        connection.registerPacket(PACKET_ZC_NOTIFY_PLAYERMOVE.self) { [weak self] packet in
            self?.onNotifyPlayerMove?(packet.moveData)
        }

        // 0x8e
        connection.registerPacket(PACKET_ZC_NOTIFY_PLAYERCHAT.self) { [weak self] packet in
        }

        // 0x91
        connection.registerPacket(PACKET_ZC_NPCACK_MAPMOVE.self) { [weak self] packet in
            var packet = PACKET_CZ_REQUEST_ACT()
            packet.targetID = 0
            packet.action = 3

            self?.connection.sendPacket(packet)

            // Load map.

            self?.notifyMapLoaded()
        }

        // 0x9c
        connection.registerPacket(PACKET_ZC_CHANGE_DIRECTION.self) { [weak self] packet in
            self?.onChangeDirection?(packet.headDirection, packet.direction)
        }

        // 0xc3, 0x1d7
        connection.registerPacket(PACKET_ZC_SPRITE_CHANGE.self) { [weak self] packet in
        }

        // 0x201
        connection.registerPacket(PACKET_ZC_FRIENDS_LIST.self) { [weak self] packet in
        }

        // 0x283
        connection.registerPacket(PACKET_ZC_AID.self) { [weak self] packet in
            self?.state.accountID = packet.accountID
        }

        // 0x2b9, 0x7d9, 0xa00, 0xb20
        connection.registerPacket(PACKET_ZC_SHORTCUT_KEY_LIST.self) { [weak self] packet in
        }

        // 0xb18
        connection.registerPacket(PACKET_ZC_EXTEND_BODYITEM_SIZE.self) { [weak self] packet in
        }

        // 0xb1d
        connection.registerPacket(PACKET_ZC_PING_LIVE.self) { [weak self] packet in
            let packet = PACKET_CZ_PING_LIVE()
            self?.connection.sendPacket(packet)
        }

        registerAchievementPackets()
        registerInventoryPackets()
        registerMailPackets()
        registerPartyPackets()
        registerStatusPackets()
    }

    private func registerAchievementPackets() {
        // 0xa23
        connection.registerPacket(PACKET_ZC_ALL_ACH_LIST.self) { [weak self] packet in
        }

        // 0xa24
        connection.registerPacket(PACKET_ZC_ACH_UPDATE.self) { [weak self] packet in
        }
    }

    private func registerInventoryPackets() {
        // 0xb08
        connection.registerPacket(PACKET_ZC_INVENTORY_START.self) { [weak self] packet in
        }

        // 0xa3, 0x1ee, 0x2e8, 0x991, 0xb09
        connection.registerPacket(PACKET_ZC_ITEMLIST_NORMAL.self) { [weak self] packet in
        }

        // 0xa4, 0x295, 0x2d0, 0x992, 0xa0d, 0xb0a, 0xb39
        connection.registerPacket(PACKET_ZC_ITEMLIST_EQUIP.self) { [weak self] packet in
        }

        // 0xb0b
        connection.registerPacket(PACKET_ZC_INVENTORY_END.self) { [weak self] packet in
        }
    }

    private func registerMailPackets() {
        // 0x24a
        connection.registerPacket(PACKET_ZC_MAIL_RECEIVE.self) { [weak self] packet in
        }

        // 0x9e7
        connection.registerPacket(PACKET_ZC_NOTIFY_UNREADMAIL.self) { [weak self] packet in
        }
    }

    private func registerPartyPackets() {
        // 0x2c9
        connection.registerPacket(PACKET_ZC_PARTY_CONFIG.self) { [weak self] packet in
        }
    }

    private func registerStatusPackets() {
        // 0xb0
        connection.registerPacket(PACKET_ZC_PAR_CHANGE.self) { [weak self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                self?.onStatusPropertyChanged?(sp, Int(packet.count), 0)
            }
        }

        // 0xb1
        connection.registerPacket(PACKET_ZC_LONGPAR_CHANGE.self) { [weak self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                self?.onStatusPropertyChanged?(sp, Int(packet.amount), 0)
            }
        }

        // 0xbd
        connection.registerPacket(PACKET_ZC_STATUS.self) { [weak self] packet in
        }

        // 0xbe
        connection.registerPacket(PACKET_ZC_STATUS_CHANGE.self) { [weak self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.statusID)) {
                self?.onStatusPropertyChanged?(sp, Int(packet.value), 0)
            }
        }

        // 0x121
        connection.registerPacket(PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.self) { [weak self] packet in
        }

        // 0x13a
        connection.registerPacket(PACKET_ZC_ATTACK_RANGE.self) { [weak self] packet in
            self?.onAttackRangeChanged?(Int(packet.currentAttackRange))
        }

        // 0x141
        connection.registerPacket(PACKET_ZC_COUPLESTATUS.self) { [weak self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.statusType)) {
                self?.onStatusPropertyChanged?(sp, Int(packet.defaultStatus), Int(packet.plusStatus))
            }
        }

        // 0xacb
        connection.registerPacket(PACKET_ZC_LONGLONGPAR_CHANGE.self) { [weak self] packet in
            if let sp = StatusProperty(rawValue: Int(packet.varID)) {
                self?.onStatusPropertyChanged?(sp, Int(packet.amount), 0)
            }
        }
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
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            var packet = PACKET_CZ_REQUEST_TIME()
            packet.clientTime = UInt32(Date.now.timeIntervalSince(startTime))

            self.connection.sendPacket(packet)
        }
        keepAliveTimer?.fire()
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

    /// Request move.
    ///
    /// Send ``PACKET_CZ_REQUEST_MOVE``
    public func requestMove(x: Int16, y: Int16) {
        var packet = PACKET_CZ_REQUEST_MOVE()
        packet.x = x
        packet.y = y

        connection.sendPacket(packet)
    }
}
