//
//  Client.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import Foundation
import Network
import ROCore

final class Client {
    var errorHandler: (@Sendable (_ error: any Error) -> Void)?

    private let connection: NWConnection

    private let packetStream: AsyncStream<PacketDecodingResult>
    private let packetContinuation: AsyncStream<PacketDecodingResult>.Continuation

    private var packetRegistrations: [Int16 : any PacketRegistration] = [:]

    init(port: UInt16) {
        self.connection = NWConnection(
            host: .ipv4(.loopback),
            port: .init(rawValue: port)!,
            using: .tcp
        )

        let (stream, continuation) = AsyncStream<PacketDecodingResult>.makeStream()
        self.packetStream = stream
        self.packetContinuation = continuation
    }

    func connect() {
        connection.stateUpdateHandler = { state in
            print(state)
        }

        let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.client")
        connection.start(queue: queue)

        Task {
            for await result in packetStream {
                let packet = result.packet
                await result.packetHandler(packet)
            }
        }
    }

    func disconnect() {
        connection.stateUpdateHandler = nil

        connection.cancel()

        packetContinuation.finish()
    }

    func registerPacket<P>(_ type: P.Type, for packetType: Int16, handler: @escaping (P) async -> Void) where P: BinaryDecodable {
        packetRegistrations[packetType] = _PacketRegistration(type: type, handler: handler)
    }

    func sendPacket(_ packet: some BinaryEncodable) {
        do {
            let encoder = PacketEncoder()
            let data = try encoder.encode(packet)

            connection.send(content: data, completion: .contentProcessed({ [weak self] error in
                if let error {
                    self?.errorHandler?(error)
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
                    let decoder = PacketDecoder(packetRegistrations: packetRegistrations)
                    let results = try decoder.decode(from: content)
                    for result in results {
                        packetContinuation.yield(result)
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
