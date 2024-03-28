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

class LoginClient {
    let packetVersion = RA_PACKETVER

    var onAcceptLogin: (() -> Void)?
    var onRefuseLogin: (() -> Void)?
    var onNotifyBan: (() -> Void)?
    var onError: ((Error) -> Void)?

    private let encoder: PacketEncoder
    private let decoder: PacketDecoder

    private let connection: NWConnection

    init() {
        encoder = PacketEncoder(packetVersion: packetVersion)
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
        var packet = Packets.CA.Login(packetVersion: packetVersion)
        packet.username = username
        packet.password = password

        let data = try encoder.encode(packet)
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
                    case let acceptLogin as Packets.AC.AcceptLogin:
                        onAcceptLogin?()
                    case let refuseLogin as Packets.AC.RefuseLogin:
                        onRefuseLogin?()
                    case let notifyBan as Packets.SC.NotifyBan:
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
