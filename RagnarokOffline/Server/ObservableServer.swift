//
//  ObservableServer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//

import Combine
import Foundation
import rAthenaCommon

class ObservableServer: ObservableObject {
    private let server: Server

    let name: String
    @Published var status: ServerStatus

    private(set) var cachedOutput = Data()
    var outputHandler: ServerOutputHandler?

    private var subscriptions = Set<AnyCancellable>()

    init(server: Server) {
        self.server = server

        name = server.name

        status = server.status
        server.publisher(for: \.status)
            .receive(on: RunLoop.main)
            .assign(to: \.status, on: self)
            .store(in: &subscriptions)

        server.outputHandler = handleOutput
    }

    func start() {
        Task {
            await server.start()
        }
    }

    private func handleOutput(_ data: Data) {
        if let data = String(data: data, encoding: .isoLatin1)?
            .replacingOccurrences(of: "\n", with: "\r\n")
            .data(using: .isoLatin1) {
            cachedOutput.append(data)
            outputHandler?(data)
        }
    }
}

extension ServerStatus: CustomStringConvertible {
    public var description: String {
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
