//
//  MapClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import Foundation

public class MapClient {
    public let state: ClientState

    public var onAcceptEnter: (() -> Void)?
    public var onNotifyPlayerMove: ((MoveData) -> Void)?
    public var onChangeDirection: ((UInt16, UInt8) -> Void)?
    public var onError: ((any Error) -> Void)?

    private let connection: ClientConnection

    private var keepAliveTimer: Timer?

    public init(state: ClientState, ip: UInt32, port: UInt16) {
        self.state = state

        let decodablePackets: [any DecodablePacket.Type] = [
            PACKET_ZC_ACCEPT_ENTER.self,                    // 0x73, 0x2eb, 0xa18
            PACKET_ZC_NOTIFY_PLAYERMOVE.self,               // 0x87
            PACKET_ZC_NOTIFY_PLAYERCHAT.self,               // 0x8e
            PACKET_ZC_NPCACK_MAPMOVE.self,                  // 0x91
            PACKET_ZC_CHANGE_DIRECTION.self,                // 0x9c
            PACKET_ZC_PAR_CHANGE.self,                      // 0xb0
            PACKET_ZC_FRIENDS_LIST.self,                    // 0x201
            PACKET_ZC_AID.self,                             // 0x283
            PACKET_ZC_EXTEND_BODYITEM_SIZE.self,            // 0xb18
            PACKET_ZC_PING_LIVE.self,                       // 0xb1d
        ]

        connection = ClientConnection(port: port, decodablePackets: decodablePackets)
    }

    public func connect() {
        connection.packetReceiveHandler = { packet in
            self.receivePacket(packet)
            self.connection.receivePacket()
        }
        connection.errorHandler = { error in
            self.onError?(error)
        }

        connection.start()
    }

    public func disconnect() {
        connection.packetReceiveHandler = nil
        connection.errorHandler = nil

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
        packet.aid = state.aid
        packet.gid = state.gid
        packet.authCode = state.authCode
        packet.clientTime = UInt32(Date.now.timeIntervalSince1970)
        packet.sex = state.sex

        connection.sendPacket(packet)

        if PACKET_VERSION < 20070521 {
            connection.receiveData { data in
                self.state.aid = data.withUnsafeBytes({ $0.load(as: UInt32.self) })

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
    public func changeDirection(headDir: UInt16, dir: UInt8) {
        var packet = PACKET_CZ_CHANGE_DIRECTION()
        packet.headDir = headDir
        packet.dir = dir

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

    private func receivePacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_ZC_ACCEPT_ENTER:
            onAcceptEnter?()
        case let packet as PACKET_ZC_NOTIFY_PLAYERMOVE:
            onNotifyPlayerMove?(packet.moveData)
        case let packet as PACKET_ZC_NOTIFY_PLAYERCHAT:
            break
        case let packet as PACKET_ZC_NPCACK_MAPMOVE:
            var packet = PACKET_CZ_REQUEST_ACT()
            packet.targetGID = 0
            packet.action = 3

            connection.sendPacket(packet)

            // Load map.

            notifyMapLoaded()
        case let packet as PACKET_ZC_CHANGE_DIRECTION:
            onChangeDirection?(packet.headDir, packet.dir)
        case let packet as PACKET_ZC_PAR_CHANGE:
            break
        case let packet as PACKET_ZC_FRIENDS_LIST:
            break
        case let packet as PACKET_ZC_AID:
            state.aid = packet.aid
        case let packet as PACKET_ZC_EXTEND_BODYITEM_SIZE:
            break
        case is PACKET_ZC_PING_LIVE:
            let packet = PACKET_CZ_PING_LIVE()
            connection.sendPacket(packet)
        default:
            break
        }
    }
}
