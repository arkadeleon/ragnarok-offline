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

    public func events<E>(for event: E.Type) -> some AsyncSequence<E, Never> where E: Event {
        AsyncStream { continuation in
            let subscription = eventPublisher
                .compactMap { e in
                    e as? E
                }
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
