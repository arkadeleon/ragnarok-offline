//
//  ClientConnection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import Combine
import Foundation
import Network
import ROCore

final class ClientConnection {
    private let connection: NWConnection

    private let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.client-connection")

    private let packetSubject = PassthroughSubject<any BinaryDecodable, Never>()

    private var registeredPackets: [Int16 : any BinaryDecodable.Type] = [:]

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

    func registerPacket<P>(_ type: P.Type, for packetType: Int16) -> AnyPublisher<P, Never> where P: BinaryDecodable {
        registeredPackets[packetType] = type

        let publisher = packetSubject
            .compactMap { packet in
                packet as? P
            }
            .eraseToAnyPublisher()
        return publisher
    }

    func sendPacket(_ packet: some BinaryEncodable) {
        do {
            let encoder = PacketEncoder()
            let data = try encoder.encode(packet)

            connection.send(content: data, completion: .contentProcessed({ error in
                if let error {
                    self.errorHandler?(error)
                }
            }))

            print("Sent packet: \(packet)")
        } catch {
            errorHandler?(error)
        }
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
                    let decoder = PacketDecoder(registeredPackets: registeredPackets)
                    let packets = try decoder.decode(from: content)
                    for packet in packets {
                        packetSubject.send(packet)
                    }
                } catch {
                    print(error)
                    self.errorHandler?(error)
                }
            }

            if let error {
                self.errorHandler?(error)
            } else {
                self.receivePacket()
            }
        }
    }
}
