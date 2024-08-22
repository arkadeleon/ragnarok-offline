//
//  MapClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import Foundation

public class MapClient {
    public let state: ClientState

    private let connection: ClientConnection

    public var onAcceptEnter: (() -> Void)?
    public var onError: ((any Error) -> Void)?

    public init(state: ClientState, ip: UInt32, port: UInt16) {
        self.state = state

        let decodablePackets: [any DecodablePacket.Type] = [
            PACKET_ZC_ACCEPT_ENTER.self,                    // 0x73, 0x2eb, 0xa18
            PACKET_ZC_NOTIFY_PLAYERCHAT.self,               // 0x8e
            PACKET_ZC_NPCACK_MAPMOVE.self,                  // 0x91
            PACKET_ZC_PAR_CHANGE.self,                      // 0xb0
            PACKET_ZC_FRIENDS_LIST.self,                    // 0x201
            PACKET_ZC_AID.self,                             // 0x283
            PACKET_ZC_EXTEND_BODYITEM_SIZE.self,            // 0xb18
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

    private func receivePacket(_ packet: any DecodablePacket) {
        switch packet {
        case let packet as PACKET_ZC_AID:
            state.aid = packet.aid
        case let packet as PACKET_ZC_ACCEPT_ENTER:
            onAcceptEnter?()
        default:
            break
        }
    }
}
