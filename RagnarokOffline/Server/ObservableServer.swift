//
//  ObservableServer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//

import Combine
import Foundation
import Observation
import rAthenaCommon

@Observable 
class ObservableServer {
    private let server: Server

    let name: String
    var status: ServerStatus
    var messages: [AttributedString]

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    init(server: Server) {
        self.server = server

        name = server.name
        status = server.status
        messages = []

        server.statusPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.status, on: self)
            .store(in: &subscriptions)

        server.outputDataPublisher
            .compactMap {
                String(data: $0, encoding: .isoLatin1)
            }
            .scan([AttributedString]()) {
                var result = $0
                if let last = result.last, last.characters.last == "\r" {
                    result.removeLast()
                }
                let output = $1
                let lines = output.split(separator: "\n")
                for line in lines where !line.isEmpty {
                    let attributedString = attributedStringForServerOutput(String(line))
                    result.append(attributedString)
                }
                if result.count > 1000 {
                    result.removeLast(result.count - 1000)
                }
                return result
            }
            .throttle(for: 0.1, scheduler: RunLoop.main, latest: true)
            .assign(to: \.messages, on: self)
            .store(in: &subscriptions)
    }

    func start() {
        Task {
            await server.start()
        }
    }
}

extension Server {
    public var statusPublisher: AnyPublisher<ServerStatus, Never> {
        publisher(for: \.status)
            .eraseToAnyPublisher()
    }

    public var outputDataPublisher: AnyPublisher<Data, Never> {
        NotificationCenter.default.publisher(for: .ServerDidOutputData, object: self)
            .map { $0.userInfo![ServerOutputDataKey] as! Data }
            .eraseToAnyPublisher()
    }
}

extension ServerStatus: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notStarted: "NOT STARTED"
        case .starting: "STARTING"
        case .running: "RUNNING"
        case .stopping: "STOPPING"
        case .stopped: "STOPPED"
        @unknown default:
            fatalError()
        }
    }
}
