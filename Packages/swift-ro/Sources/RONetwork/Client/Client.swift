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

    init(address: String, port: UInt16) {
        self.connection = NWConnection(
            host: NWEndpoint.Host(address),
            port: NWEndpoint.Port(rawValue: port)!,
            using: .tcp
        )

        let (stream, continuation) = AsyncStream<PacketDecodingResult>.makeStream()
        self.packetStream = stream
        self.packetContinuation = continuation
    }

    func connect() {
        connection.stateUpdateHandler = { state in
            logger.info("\(String(describing: state))")
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

            logger.info("Sent packet: \(String(describing: packet))")
        } catch {
            errorHandler?(error)
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
                        let decoder = PacketDecoder(packetRegistrations: packetRegistrations)
                        let results = try decoder.decode(from: remaining)
                        for result in results {
                            packetContinuation.yield(result)
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

    func receivePacket() {
        connection.receive(minimumIncompleteLength: 2, maximumLength: 65536) { [weak self] content, _, _, error in
            guard let self else {
                return
            }

            if let content {
                logger.info("Received \(content.count) bytes")
                do {
                    let decoder = PacketDecoder(packetRegistrations: packetRegistrations)
                    let results = try decoder.decode(from: content)
                    for result in results {
                        packetContinuation.yield(result)
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
