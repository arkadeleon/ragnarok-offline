//
//  SessionProtocol.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/11.
//

@preconcurrency import Combine
import Dispatch

public protocol SessionProtocol {
    var eventPublisher: AnyPublisher<any Event, Never> { get }

    func start()
    func stop()
}

extension SessionProtocol {
    public func publisher<E>(for event: E.Type) -> AnyPublisher<E, Never> where E: Event {
        eventPublisher
            .compactMap { e in
                e as? E
            }
            .receive(on: DispatchQueue.main, options: DispatchQueue.SchedulerOptions(qos: .userInteractive))
            .eraseToAnyPublisher()
    }

    public func subscribe<E>(to event: E.Type, handler: @escaping @MainActor (E) -> Void) -> AnyCancellable where E: Event {
        eventPublisher
            .compactMap { e in
                e as? E
            }
            .receive(on: DispatchQueue.main, options: DispatchQueue.SchedulerOptions(qos: .userInteractive))
            .sink { e in
                MainActor.assumeIsolated {
                    handler(e)
                }
            }
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
