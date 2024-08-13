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

    public func enter() {
        var packet = PACKET_CH_ENTER()
        packet.aid = state.aid
        packet.authCode = state.authCode
        packet.userLevel = state.userLevel
        packet.sex = state.sex
        packet.clientType = state.langType

        connection.sendPacket(packet)

        connection.receiveData { data in
            // state.aid = data

            self.connection.receivePacket()
        }
    }

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

    public func selectChar(charNum: UInt8) {
        var packet = PACKET_CH_SELECT_CHAR()
        packet.charNum = charNum

        connection.sendPacket(packet)
    }

    public func keepAlive() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
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
        case let packet as PACKET_HC_ACCEPT_MAKECHAR_NEO_UNION:
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

    private func receiveAcceptMakeCharPacket(_ packet: PACKET_HC_ACCEPT_MAKECHAR_NEO_UNION) {
        onAcceptMakeChar?()
    }

    private func receiveRefuseMakeCharPacket(_ packet: PACKET_HC_REFUSE_MAKECHAR) {
        onRefuseMakeChar?()
    }
}
