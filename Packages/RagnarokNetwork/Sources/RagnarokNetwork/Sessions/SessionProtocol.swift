//
//  SessionProtocol.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/12/11.
//

@preconcurrency import Combine

public protocol SessionProtocol {
    associatedtype Event: Sendable

    var eventPublisher: AnyPublisher<Self.Event, Never> { get }

    func start()
    func stop()
}

extension SessionProtocol {
    public var events: AsyncStream<Self.Event> {
        AsyncStream { continuation in
            let subscription = eventPublisher
                .sink { completion in
                    continuation.finish()
                } receiveValue: { e in
                    continuation.yield(e)
                }
            continuation.onTermination = { termination in
                subscription.cancel()
            }
        }
    }
}
