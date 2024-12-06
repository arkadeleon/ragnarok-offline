//
//  ClientBase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import Combine
import Foundation
import Network
import ROCore

public class ClientBase {
    private let connection: NWConnection

    private let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.client-base")

    private var registeredPackets: [Int16 : any BinaryDecodable.Type] = [:]

    private let packetSubject = PassthroughSubject<any BinaryDecodable, Never>()
    private let eventSubject = PassthroughSubject<any Event, Never>()
    private let errorSubject = PassthroughSubject<any Error, Never>()

    private var subscriptions = Set<AnyCancellable>()

    init(port: UInt16) {
        connection = NWConnection(
            host: .ipv4(.loopback),
            port: .init(rawValue: port)!,
            using: .tcp
        )

        errorSubject
            .map { error in
                ConnectionEvents.ErrorOccurred(error: error)
            }
            .subscribe(eventSubject)
            .store(in: &subscriptions)
    }

    public func connect() {
        connection.stateUpdateHandler = { state in
            print(state)
        }

        connection.start(queue: queue)
    }

    public func disconnect() {
        connection.stateUpdateHandler = nil

        connection.cancel()
    }

    // MARK: - Event

    public func subscribe<E>(to event: E.Type, _ handler: @escaping (E) -> Void) -> any Cancellable where E: Event {
        let cancellable = eventSubject
            .compactMap { event in
                event as? E
            }
            .receive(on: RunLoop.main)
            .sink(receiveValue: handler)
        return cancellable
    }

    func postEvent(_ event: some Event) {
        eventSubject.send(event)
    }

    // MARK: - Packet

    func registerPacket<P>(_ type: P.Type, for packetType: Int16, _ handler: @escaping (P) -> Void) where P: BinaryDecodable {
        registeredPackets[packetType] = type

        packetSubject
            .compactMap { packet in
                packet as? P
            }
            .sink { packet in
                handler(packet)
            }
            .store(in: &subscriptions)
    }

    func sendPacket(_ packet: some BinaryEncodable) {
        do {
            let encoder = PacketEncoder()
            let data = try encoder.encode(packet)

            connection.send(content: data, completion: .contentProcessed({ [weak self] error in
                if let error {
                    self?.errorSubject.send(error)
                }
            }))

            print("Sent packet: \(packet)")
        } catch {
            errorSubject.send(error)
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
                    self.errorSubject.send(error)
                }
            }

            if let error {
                self.errorSubject.send(error)
            } else {
                self.receivePacket()
            }
        }
    }
}
