//
//  ObservableServer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//

import Combine
import Foundation
import Observation
import ROServer
import SwiftUI

@Observable 
class ObservableServer {
    private let server: ServerWrapper

    let name: String
    var status: ServerWrapper.Status
    var messages: [AttributedString]

    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()

    init(server: ServerWrapper) {
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
                    let attributedString = AttributedString(logMessage: String(line))
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

extension EnvironmentValues {
    @Entry var loginServer = ObservableServer(server: .login)
    @Entry var charServer = ObservableServer(server: .char)
    @Entry var mapServer = ObservableServer(server: .map)
    @Entry var webServer = ObservableServer(server: .web)
}
