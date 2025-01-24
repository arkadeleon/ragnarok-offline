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
    private enum ConsoleAction {
        case append(Data)
        case clear

        init(_ data: Data) {
            self = .append(data)
        }
    }

    private let server: ServerWrapper

    let name: String
    var status: ServerWrapper.Status
    var messages: [AttributedString]

    @ObservationIgnored
    private let consoleActionSubject = PassthroughSubject<ConsoleAction, Never>()

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

        let queue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.server-output", qos: .userInitiated)
        server.outputDataPublisher
            .receive(on: queue)
            .map(ConsoleAction.init)
            .merge(with: consoleActionSubject)
            .scan([AttributedString]()) { result, action in
                switch action {
                case .append(let data):
                    var result = result
                    guard let output = String(data: data, encoding: .isoLatin1) else {
                        return result
                    }
                    if let last = result.last, last.characters.last == "\r" {
                        result.removeLast()
                    }
                    let lines = output.split(separator: "\n")
                    for line in lines where !line.isEmpty {
                        let attributedString = AttributedString(logMessage: String(line))
                        result.append(attributedString)
                    }
                    if result.count > 1000 {
                        result.removeLast(result.count - 1000)
                    }
                    return result
                case .clear:
                    return []
                }
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

    func stop() {
        Task {
            await server.stop()
        }
    }

    func clearConsole() {
        consoleActionSubject.send(.clear)
    }
}

extension EnvironmentValues {
    @Entry var loginServer = ObservableServer(server: .login)
    @Entry var charServer = ObservableServer(server: .char)
    @Entry var mapServer = ObservableServer(server: .map)
    @Entry var webServer = ObservableServer(server: .web)
}
