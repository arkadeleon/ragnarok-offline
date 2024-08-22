//
//  ClientConnection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import Foundation
import Network

class ClientConnection {
    let connection: NWConnection

    private let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.client-connection")

    private let packetEncoder: PacketEncoder
    private let packetDecoder: PacketDecoder

    var packetReceiveHandler: (@Sendable (any DecodablePacket) -> Void)?
    var errorHandler: (@Sendable (any Error) -> Void)?

    init(port: UInt16, decodablePackets: [any DecodablePacket.Type]) {
        connection = NWConnection(
            host: .ipv4(.loopback),
            port: .init(rawValue: port)!,
            using: .tcp
        )

        packetEncoder = PacketEncoder()

        packetDecoder = PacketDecoder(decodablePackets: decodablePackets)
    }

    func start() {
        connection.stateUpdateHandler = { state in
            print(state)
        }

        connection.start(queue: queue)
    }

    func cancel() {
        connection.stateUpdateHandler = nil

        connection.cancel()
    }

    func sendPacket(_ packet: some EncodablePacket) {
        let data: Data
        do {
            data = try packetEncoder.encode(packet)
        } catch {
            errorHandler?(error)
            return
        }

        connection.send(content: data, completion: .contentProcessed({ error in
            if let error {
                self.errorHandler?(error)
            }
        }))
    }

    func receiveData(completion: @escaping @Sendable (_ data: Data) -> Void) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { content, _, _, error in
            if let content {
                completion(content)
            }
        }
    }

    func receivePacket() {
        connection.receive(minimumIncompleteLength: 2, maximumLength: 65536) { content, _, _, error in
            if let content {
                do {
                    let packets = try self.packetDecoder.decode(from: content)
                    for packet in packets {
                        print(packet)
                        self.packetReceiveHandler?(packet)
                    }
                } catch {
                    print(error)
                    self.errorHandler?(error)
                }
            } else if let error {
                self.errorHandler?(error)
            }
        }
    }
}
