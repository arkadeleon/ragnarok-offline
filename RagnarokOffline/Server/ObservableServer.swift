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

    let terminalView: TerminalView

    @ObservationIgnored private var subscriptions = Set<AnyCancellable>()

    init(server: Server) {
        self.server = server

        name = server.name
        status = server.status

        terminalView = TerminalView()

        server.statusPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.status, on: self)
            .store(in: &subscriptions)

        server.outputDataPublisher
            .compactMap { data in
                String(data: data, encoding: .isoLatin1)?
                    .replacingOccurrences(of: "\n", with: "\r\n")
            }
            .collect(.byTime(RunLoop.main, .milliseconds(500)))
            .sink { [weak self] texts in
                self?.terminalView.feed(text: texts.joined())
            }
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
        @unknown default: ""
        }
    }
}
