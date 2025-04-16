//
//  Client.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import Foundation
import Network
import ROCore
import ROPackets

public enum ClientError: Error {
    case decoding(any Error)
    case encoding(any Error)
    case network(NWError)
}

final public class Client: Sendable {
    private let name: String
    private let connection: NWConnection

    private let errorStream: AsyncStream<ClientError>
    private let errorContinuation: AsyncStream<ClientError>.Continuation

    private let packetStream: AsyncStream<any RegisteredPacket>
    private let packetContinuation: AsyncStream<any RegisteredPacket>.Continuation

    public init(name: String, address: String, port: UInt16) {
        self.name = name
        self.connection = NWConnection(
            host: NWEndpoint.Host(address),
            port: NWEndpoint.Port(rawValue: port)!,
            using: .tcp
        )

        let (errorStream, errorContinuation) = AsyncStream<ClientError>.makeStream()
        self.errorStream = errorStream
        self.errorContinuation = errorContinuation

        let (packetStream, packetContinuation) = AsyncStream<any RegisteredPacket>.makeStream()
        self.packetStream = packetStream
        self.packetContinuation = packetContinuation
    }

    public func connect(with subscription: ClientSubscription) {
        let name = name
        connection.stateUpdateHandler = { state in
            logger.info("\(name) client \(String(describing: state))")
        }

        let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.client")
        connection.start(queue: queue)

        let errorHandlers = subscription.errorHandlers
        let packetHandlers = subscription.packetHandlers

        Task {
            for await error in errorStream {
                for errorHandler in errorHandlers {
                    errorHandler(error)
                }
            }
        }

        Task {
            for await packet in packetStream {
                for packetHandler in packetHandlers {
                    if type(of: packet) == packetHandler.type {
                        packetHandler.handlePacket(packet)
                    }
                }
            }
        }
    }

    public func disconnect() {
        connection.stateUpdateHandler = nil

        connection.cancel()

        errorContinuation.finish()
        packetContinuation.finish()
    }

    public func sendPacket(_ packet: some BinaryEncodable) {
        do {
            let encoder = PacketEncoder()
            let data = try encoder.encode(packet)

            connection.send(content: data, completion: .contentProcessed({ [weak self] error in
                if let error {
                    self?.errorContinuation.yield(.network(error))
                }
            }))

            logger.info("Sent packet: \(String(describing: packet))")
        } catch {
            errorContinuation.yield(.encoding(error))
        }
    }

    public func receiveDataAndPacket(count: Int, completion: @escaping @Sendable (_ data: Data) -> Void) {
        connection.receive(minimumIncompleteLength: count, maximumLength: 65536) { [weak self] content, _, _, error in
            guard let self else {
                return
            }

            if let content {
                logger.info("Received \(content.count) bytes")
                if content.count >= count {
                    let data = content[0..<count]
                    completion(data)

                    let remaining = content[count...]
                    do {
                        let decoder = PacketDecoder()
                        let packets = try decoder.decode(from: remaining)
                        for packet in packets {
                            logger.info("Received packet: \(String(describing: packet))")
                            packetContinuation.yield(packet)
                        }
                    } catch {
                        logger.warning("\(error.localizedDescription)")
                        self.errorContinuation.yield(.decoding(error))
                    }
                }
            }

            if let error {
                self.errorContinuation.yield(.network(error))
            } else {
                self.receivePacket()
            }
        }
    }

    public func receivePacket() {
        connection.receive(minimumIncompleteLength: 2, maximumLength: 65536) { [weak self] content, _, _, error in
            guard let self else {
                return
            }

            if let content {
                logger.info("Received \(content.count) bytes")
                do {
                    let decoder = PacketDecoder()
                    let packets = try decoder.decode(from: content)
                    for packet in packets {
                        packetContinuation.yield(packet)
                    }
                } catch {
                    logger.warning("\(error.localizedDescription)")
                    self.errorContinuation.yield(.decoding(error))
                }
            }

            if let error {
                self.errorContinuation.yield(.network(error))
            } else {
                self.receivePacket()
            }
        }
    }
}
