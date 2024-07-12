//
//  LoginClient.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import Network

/// Login client.
///
/// Sendable packets:
/// - ``PACKET_CA_LOGIN``
/// - ``PACKET_CA_CONNECT_INFO_CHANGED``
/// - ``PACKET_CA_EXE_HASHCHECK``
///
/// Receivable packets:
/// - ``PACKET_AC_ACCEPT_LOGIN``
/// - ``PACKET_AC_REFUSE_LOGIN``
/// - ``PACKET_SC_NOTIFY_BAN``
public class LoginClient {
    public var onAcceptLogin: (() -> Void)?
    public var onRefuseLogin: (() -> Void)?
    public var onNotifyBan: (() -> Void)?
    public var onError: ((any Error) -> Void)?

    private let encoder: PacketEncoder
    private let decoder: PacketDecoder

    private let connection: NWConnection

    public init() {
        encoder = PacketEncoder()
        decoder = PacketDecoder()

        connection = NWConnection(host: .ipv4(.loopback), port: 6900, using: .tcp)
    }

    public func connect() {
        let queue = DispatchQueue(label: "")
        connection.start(queue: queue)

        connection.stateUpdateHandler = { state in
            print(state)
        }

        receiveNext()
    }

    public func login(username: String, password: String) throws {
        var login = PACKET_CA_LOGIN()
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
                    case let acceptLogin as PACKET_AC_ACCEPT_LOGIN:
                        onAcceptLogin?()
                    case let refuseLogin as PACKET_AC_REFUSE_LOGIN:
                        onRefuseLogin?()
                    case let notifyBan as PACKET_SC_NOTIFY_BAN:
                        onNotifyBan?()
                    default:
                        onError?(PacketDecodingError.unknownPacket(packet.packetType))
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
