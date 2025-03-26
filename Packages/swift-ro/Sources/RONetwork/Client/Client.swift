//
//  Client.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import Foundation
import Network
import ROCore

final public class Client: @unchecked Sendable {
    public var errorHandler: (@Sendable (_ error: any Error) -> Void)?

    private let name: String
    private let connection: NWConnection

    private let packetStream: AsyncStream<any BinaryDecodable>
    private let packetContinuation: AsyncStream<any BinaryDecodable>.Continuation

    private var packetHandlers: [any PacketHandlerProtocol] = []

    public init(name: String, address: String, port: UInt16) {
        self.name = name
        self.connection = NWConnection(
            host: NWEndpoint.Host(address),
            port: NWEndpoint.Port(rawValue: port)!,
            using: .tcp
        )

        let (stream, continuation) = AsyncStream<any BinaryDecodable>.makeStream()
        self.packetStream = stream
        self.packetContinuation = continuation
    }

    public func connect() {
        let name = name
        connection.stateUpdateHandler = { state in
            logger.info("\(name) client \(String(describing: state))")
        }

        let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.client")
        connection.start(queue: queue)

        Task {
            for await packet in packetStream {
                for packetHandler in packetHandlers {
                    if type(of: packet) == packetHandler.type {
                        await packetHandler.handlePacket(packet)
                    }
                }
            }
        }
    }

    public func disconnect() {
        connection.stateUpdateHandler = nil

        connection.cancel()

        packetContinuation.finish()
    }

    public func subscribe<P>(to type: P.Type, _ handler: @escaping (P) async -> Void) where P: BinaryDecodable {
        let packetHandler = PacketHandler(type: type, handler: handler)
        packetHandlers.append(packetHandler)
    }

    public func sendPacket(_ packet: some BinaryEncodable) {
        do {
            let encoder = PacketEncoder()
            let data = try encoder.encode(packet)

            connection.send(content: data, completion: .contentProcessed({ [weak self] error in
                if let error {
                    self?.errorHandler?(error)
                }
            }))

            logger.info("Sent packet: \(String(describing: packet))")
        } catch {
            errorHandler?(error)
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
                            packetContinuation.yield(packet)
                        }
                    } catch {
                        logger.warning("\(error.localizedDescription)")
                        self.errorHandler?(error)
                    }
                }
            }

            if let error {
                self.errorHandler?(error)
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
