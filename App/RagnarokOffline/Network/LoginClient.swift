//
//  LoginClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Network
import rAthenaCommon
import rAthenaNetwork

/// Login client.
///
/// Sendable packets:
/// - PACKET.CA.LOGIN
/// - PACKET_CA_CONNECT_INFO_CHANGED
/// - PACKET_CA_EXE_HASHCHECK
///
/// Receivable packets:
/// - PACKET_AC_ACCEPT_LOGIN
/// - PACKET_AC_REFUSE_LOGIN
/// - PACKET_SC_NOTIFY_BAN
class LoginClient {
    let packetVersion = PacketVersion(number: RA_PACKETVER)

    var onAcceptLogin: (() -> Void)?
    var onRefuseLogin: (() -> Void)?
    var onNotifyBan: (() -> Void)?
    var onError: ((Error) -> Void)?

    private let encoder: PacketEncoder
    private let decoder: PacketDecoder

    private let connection: NWConnection

    init() {
        encoder = PacketEncoder()
        decoder = PacketDecoder(packetVersion: packetVersion)

        connection = NWConnection(host: .ipv4(.loopback), port: 6900, using: .tcp)
    }

    func connect() {
        let queue = DispatchQueue(label: "")
        connection.start(queue: queue)

        connection.stateUpdateHandler = { state in
            print(state)
        }

        receiveNext()
    }

    func login(username: String, password: String) throws {
        var login = PACKET.CA.LOGIN(packetVersion: packetVersion)
        login.username = username
        login.password = password

        let data = try encoder.encode(login)
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error {
                self.onError?(error)
            }
        }))
    }

    private func receiveNext() {
        connection.receive(minimumIncompleteLength: 2, maximumLength: 1000) { [weak self] content, contentContext, isComplete, error in
            if let content, let self {
                do {
                    let packet = try decoder.decode(from: content)
                    switch packet {
                    case let acceptLogin as PACKET.AC.ACCEPT_LOGIN:
                        onAcceptLogin?()
                    case let refuseLogin as PACKET.AC.REFUSE_LOGIN:
                        onRefuseLogin?()
                    case let notifyBan as PACKET.SC.NOTIFY_BAN:
                        onNotifyBan?()
                    default:
                        break
                    }
                } catch {
                    onError?(error)
                }
            }
            if let error {
                self?.onError?(error)
            }

            self?.receiveNext()
        }
    }
}
