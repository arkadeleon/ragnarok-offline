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

        connection = ClientConnection(port: serverInfo.port)
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

    /// Send ``PACKET_CH_ENTER``
    /// Receive Account ID
    /// Receive ``PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER``
    /// Receive ``PACKET_HC_ACCEPT_ENTER_NEO_UNION``
    /// Receive ``PACKET_HC_CHARLIST_NOTIFY``
    /// Receive ``PACKET_HC_BLOCK_CHARACTER``
    /// Receive ``PACKET_HC_SECOND_PASSWD_LOGIN``
    /// Receive ``PACKET_HC_REFUSE_ENTER`` on failure
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

    /// Send ``PACKET_CH_MAKE_CHAR``
    /// Receive ``PACKET_HC_ACCEPT_MAKECHAR_NEO_UNION``
    /// Receive ``PACKET_HC_REFUSE_MAKECHAR``
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

    /// Send ``PACKET_CH_DELETE_CHAR``
    /// Receive ``PACKET_HC_ACCEPT_DELETECHAR``
    /// Receive ``PACKET_HC_REFUSE_DELETECHAR``
    /// Receive ``PACKET_HC_DELETE_CHAR``
    public func deleteChar(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR()
        packet.gid = charID

        connection.sendPacket(packet)
    }

    /// Send ``PACKET_CH_DELETE_CHAR_RESERVED``
    /// Receive ``PACKET_HC_DELETE_CHAR_RESERVED``
    public func requestDeletionDate(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_RESERVED()
        packet.gid = charID

        connection.sendPacket(packet)
    }

    /// Send ``PACKET_CH_DELETE_CHAR_CANCEL``
    /// Receive ``PACKET_HC_DELETE_CHAR_CANCEL``
    public func cancelDelete(charID: UInt32) {
        var packet = PACKET_CH_DELETE_CHAR_CANCEL()
        packet.gid = charID

        connection.sendPacket(packet)
    }

    /// Send ``PACKET_CH_SELECT_CHAR``
    /// Receive ``PACKET_HC_NOTIFY_ZONESVR``
    public func selectChar(charNum: UInt8) {
        var packet = PACKET_CH_SELECT_CHAR()
        packet.charNum = charNum

        connection.sendPacket(packet)
    }

    /// Send ``PACKET_CZ_PING`` every 12 seconds
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
            receiveAcceptEnterHeaderPacket(packet)
        case let packet as PACKET_HC_ACCEPT_ENTER_NEO_UNION:
            receiveAcceptEnterPacket(packet)
        case let packet as PACKET_HC_REFUSE_ENTER:
            receiveRefuseEnterPacket(packet)
        case let packet as PACKET_HC_ACCEPT_MAKECHAR:
            receiveAcceptMakeCharPacket(packet)
        case let packet as PACKET_HC_REFUSE_MAKECHAR:
            receiveRefuseMakeCharPacket(packet)
        case let packet as PACKET_HC_NOTIFY_ZONESVR:
            onNotifyZoneServer?(packet.mapName, packet.serverInfo.ip, packet.serverInfo.port)
        default:
            break
        }
    }

    private func receiveAcceptEnterHeaderPacket(_ packet: PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER) {
        onAcceptEnterHeader?()
    }

    private func receiveAcceptEnterPacket(_ packet: PACKET_HC_ACCEPT_ENTER_NEO_UNION) {
        onAcceptEnter?(packet.charList)
    }

    private func receiveRefuseEnterPacket(_ packet: PACKET_HC_REFUSE_ENTER) {
        onRefuseEnter?()
    }

    private func receiveAcceptMakeCharPacket(_ packet: PACKET_HC_ACCEPT_MAKECHAR) {
        onAcceptMakeChar?()
    }

    private func receiveRefuseMakeCharPacket(_ packet: PACKET_HC_REFUSE_MAKECHAR) {
        onRefuseMakeChar?()
    }
}
