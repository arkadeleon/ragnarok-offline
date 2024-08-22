//
//  CharClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/8.
//

import Foundation

public class CharClient {
    public let state: ClientState

    private let connection: ClientConnection

    public var onAcceptEnterHeader: (() -> Void)?
    public var onAcceptEnter: (([CharInfo]) -> Void)?
    public var onRefuseEnter: (() -> Void)?
    public var onAcceptMakeChar: (() -> Void)?
    public var onRefuseMakeChar: (() -> Void)?
    public var onNotifyZoneServer: ((String, UInt32, UInt16) -> Void)?
    public var onError: ((any Error) -> Void)?

    public init(state: ClientState, serverInfo: ServerInfo) {
        self.state = state

        let decodablePackets: [any DecodablePacket.Type] = [
            PACKET_HC_ACCEPT_ENTER_NEO_UNION.self,          // 0x6b
            PACKET_HC_REFUSE_ENTER.self,                    // 0x6c
            PACKET_HC_ACCEPT_MAKECHAR.self,                 // 0b6d
            PACKET_HC_REFUSE_MAKECHAR.self,                 // 0x6e
            PACKET_HC_ACCEPT_DELETECHAR.self,               // 0x6f
            PACKET_HC_REFUSE_DELETECHAR.self,               // 0x70
            PACKET_HC_NOTIFY_ZONESVR.self,                  // 0x71, 0xac5
            PACKET_HC_BLOCK_CHARACTER.self,                 // 0x20d
            PACKET_HC_DELETE_CHAR_RESERVED.self,            // 0x828
            PACKET_HC_DELETE_CHAR.self,                     // 0x82a
            PACKET_HC_DELETE_CHAR_CANCEL.self,              // 0x82c
            PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.self,   // 0x82d
            PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self,       // 0x840
            PACKET_HC_SECOND_PASSWD_LOGIN.self,             // 0x8b9
            PACKET_HC_CHARLIST_NOTIFY.self,                 // 0x9a0
        ]

        connection = ClientConnection(port: serverInfo.port, decodablePackets: decodablePackets)
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
    /// Send ``PACKET_CH_ENTER``
    ///
    /// Receive Account ID
    ///
    /// Receive ``PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER`` +
    ///         ``PACKET_HC_ACCEPT_ENTER_NEO_UNION`` +
    ///         ``PACKET_HC_CHARLIST_NOTIFY`` +
    ///         ``PACKET_HC_BLOCK_CHARACTER`` +
    ///         ``PACKET_HC_SECOND_PASSWD_LOGIN`` or
    ///         ``PACKET_HC_REFUSE_ENTER``
    public func enter() {
        var packet = PACKET_CH_ENTER()
        packet.aid = state.aid
        packet.authCode = state.authCode
        packet.userLevel = state.userLevel
        packet.sex = state.sex
        packet.clientType = state.langType

        connection.sendPacket(packet)

        connection.receiveData { data in
            self.state.aid = data.withUnsafeBytes({ $0.load(as: UInt32.self) })

            self.connection.receivePacket()
        }
    }

    /// Make char.
    ///
    /// Send ``PACKET_CH_MAKE_CHAR``
    ///
    /// Receive ``PACKET_HC_ACCEPT_MAKECHAR`` or
    ///         ``PACKET_HC_REFUSE_MAKECHAR``
    public func makeChar(name: String, str: UInt8, agi: UInt8, vit: UInt8, int: UInt8, dex: UInt8, luk: UInt8) {
        var packet = PACKET_CH_MAKE_CHAR()
        packet.name = name
        packet.str = str
        packet.agi = agi
        packet.vit = vit
        packet.int = int
        packet.dex = dex
        packet.luk = luk

        connection.sendPacket(packet)
    }

    /// Delete char.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR``
    ///
    /// if ``PACKET_VERSION`` > 20100803
    ///
    /// Receive ``PACKET_HC_ACCEPT_DELETECHAR`` or
    ///         ``PACKET_HC_REFUSE_DELETECHAR``
    ///
    /// else
    ///
    /// Receive ``PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER`` +
    ///         ``PACKET_HC_ACCEPT_ENTER_NEO_UNION`` +
    ///         ``PACKET_HC_CHARLIST_NOTIFY`` +
    ///         ``PACKET_HC_BLOCK_CHARACTER`` +
    ///         ``PACKET_HC_DELETE_CHAR``
    public func deleteChar(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR()
        packet.gid = charID

        connection.sendPacket(packet)
    }

    /// Request deletion date.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR_RESERVED``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR_RESERVED``
    public func requestDeletionDate(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_RESERVED()
        packet.gid = charID

        connection.sendPacket(packet)
    }

    /// Cancel delete.
    ///
    /// Send ``PACKET_CH_DELETE_CHAR_CANCEL``
    ///
    /// Receive ``PACKET_HC_DELETE_CHAR_CANCEL``
    public func cancelDelete(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_CANCEL()
        packet.gid = charID

        connection.sendPacket(packet)
    }

    /// Select char.
    ///
    /// Send ``PACKET_CH_SELECT_CHAR``
    ///
    /// Receive (
    ///     ``PACKET_VERSION`` >= 20100714 ? ``PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME`` : ``PACKET_SC_NOTIFY_BAN``
    /// ) when map server is not available.
    ///
    /// Receive ``PACKET_HC_REFUSE_ENTER`` when refused.
    ///
    /// Receive ``PACKET_HC_NOTIFY_ZONESVR`` when accepted.
    public func selectChar(charNum: UInt8) {
        var packet = PACKET_CH_SELECT_CHAR()
        packet.charNum = charNum

        connection.sendPacket(packet)
    }

    /// Keep alive.
    ///
    /// Send ``PACKET_CZ_PING`` every 12 seconds.
    public func keepAlive() {
        Timer.scheduledTimer(withTimeInterval: 12, repeats: true) { _ in
            var packet = PACKET_CZ_PING()
            packet.aid = self.state.aid

            self.connection.sendPacket(packet)
        }
    }

    private func receivePacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER:
            onAcceptEnterHeader?()
        case let packet as PACKET_HC_ACCEPT_ENTER_NEO_UNION:
            onAcceptEnter?(packet.charList)
        case let packet as PACKET_HC_REFUSE_ENTER:
            onRefuseEnter?()
        case let packet as PACKET_HC_ACCEPT_MAKECHAR:
            onAcceptMakeChar?()
        case let packet as PACKET_HC_REFUSE_MAKECHAR:
            onRefuseMakeChar?()
        case let packet as PACKET_HC_NOTIFY_ZONESVR:
            state.gid = packet.gid
            onNotifyZoneServer?(packet.mapName, packet.serverInfo.ip, packet.serverInfo.port)
        default:
            break
        }
    }
}
