//
//  Client.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/8/12.
//

import BinaryIO
import Foundation
import Network
import RagnarokPackets

public enum ClientError: Error, Sendable {
    case decoding(any Error)
    case encoding(any Error)
    case network(NWError)
}

public final class Client: Sendable {
    private let name: String
    private let connection: NWConnection

    public let errorStream: AsyncStream<ClientError>
    private let errorContinuation: AsyncStream<ClientError>.Continuation

    public let packetStream: AsyncStream<any DecodablePacket>
    private let packetContinuation: AsyncStream<any DecodablePacket>.Continuation

    public init(name: String, address: String, port: UInt16) {
        self.name = name

        let tcp = NWProtocolTCP.Options()
        tcp.connectionTimeout = 10

        self.connection = NWConnection(
            host: NWEndpoint.Host(address),
            port: NWEndpoint.Port(rawValue: port)!,
            using: NWParameters(tls: nil, tcp: tcp)
        )

        let (errorStream, errorContinuation) = AsyncStream<ClientError>.makeStream()
        self.errorStream = errorStream
        self.errorContinuation = errorContinuation

        let (packetStream, packetContinuation) = AsyncStream<any DecodablePacket>.makeStream()
        self.packetStream = packetStream
        self.packetContinuation = packetContinuation
    }

    public func connect() {
        let name = name
        let errorContinuation = errorContinuation

        connection.stateUpdateHandler = { state in
            logger.info("\(name) client connection state changed: \(String(describing: state))")

            switch state {
            case .waiting(let error), .failed(let error):
                errorContinuation.yield(.network(error))
            default:
                break
            }
        }

        let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.client")
        connection.start(queue: queue)
    }

    public func disconnect() {
        connection.stateUpdateHandler = nil

        connection.cancel()

        errorContinuation.finish()
        packetContinuation.finish()
    }

    public func sendPacket(_ packet: some EncodablePacket) {
        do {
            let encoder = PacketEncoder()
            let data = try encoder.encode(packet)

            connection.send(content: data, completion: .contentProcessed({ [weak self] error in
                if let error {
                    self?.errorContinuation.yield(.network(error))
                } else {
                    logger.info("Sent packet: \(String(describing: packet))")
                }
            }))
        } catch {
            errorContinuation.yield(.encoding(error))
        }
    }

    func receiveDataAndPacket(count: Int, completion: @escaping @Sendable (_ data: Data) -> Void) {
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
                        logger.warning("\(error)")
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

    func receivePacket() {
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
                        logger.info("Received packet: \(String(describing: packet))")
                        packetContinuation.yield(packet)
                    }
                } catch {
                    logger.warning("\(error)")
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
