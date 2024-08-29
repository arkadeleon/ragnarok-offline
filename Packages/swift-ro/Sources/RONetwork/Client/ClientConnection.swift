//
//  ClientConnection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import Foundation
import Network

final class ClientConnection {
    private let connection: NWConnection

    private let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.client-connection")

    private let packetEncoder = PacketEncoder()
    private let packetDecoder = PacketDecoder()

    private var packetRegistrations: [any PacketRegistration] = []

    var errorHandler: (@Sendable (_ error: any Error) -> Void)?

    init(port: UInt16) {
        connection = NWConnection(
            host: .ipv4(.loopback),
            port: .init(rawValue: port)!,
            using: .tcp
        )
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

    func registerPacket<P>(_ type: P.Type, receiveHandler: @escaping (P) -> Void) where P: DecodablePacket {
        packetDecoder.registerPacket(type)

        let registration = _PacketRegistration(packetType: type.packetType, handler: receiveHandler)
        packetRegistrations.append(registration)
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

        print("Sent packet: \(packet)")
    }

    func receiveData(completion: @escaping @Sendable (_ data: Data) -> Void) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { content, _, _, error in
            if let content {
                completion(content)
            }
        }
    }

    func receivePacket() {
        connection.receive(minimumIncompleteLength: 2, maximumLength: 65536) { [weak self] content, _, _, error in
            guard let self else {
                return
            }

            if let content {
                print("Received \(content.count) bytes")
                do {
                    let packets = try self.packetDecoder.decode(from: content)
                    for packet in packets {
                        if let registration = self.packetRegistrations.first(where: { $0.packetType == packet.packetType }) {
                            registration.handlePacket(packet)
                        }
                    }
                } catch {
                    print(error)
                    self.errorHandler?(error)
                }
            } else if let error {
                self.errorHandler?(error)
            }

            self.receivePacket()
        }
    }
}
