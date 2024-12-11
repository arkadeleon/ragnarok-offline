//
//  SessionProtocol.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/11.
//

import Combine
import Foundation

public protocol SessionProtocol {
    var eventPublisher: AnyPublisher<any Event, Never> { get }

    func start()
    func stop()
}

extension SessionProtocol {
    public func subscribe<E>(to event: E.Type, _ handler: @escaping (E) -> Void) -> AnyCancellable where E: Event {
        let subscription = eventPublisher
            .compactMap { e in
                e as? E
            }
            .receive(on: RunLoop.main)
            .sink(receiveValue: handler)
        return subscription
    }

    public func eventStream<E>(for event: E.Type) -> AsyncStream<E> where E: Event {
        AsyncStream { continuation in
            let subscription = eventPublisher
                .compactMap { event in
                    event as? E
                }
                .sink { event in
                    continuation.yield(event)
                }
            continuation.onTermination = { termination in
                subscription.cancel()
            }
        }
    }
}
