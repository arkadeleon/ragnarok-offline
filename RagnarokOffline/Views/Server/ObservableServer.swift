//
//  ObservableServer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Combine
import Foundation
import rAthenaCommon

class ObservableServer: ObservableObject {
    private let server: Server

    let name: String
    let terminalView = TerminalView()

    @Published var status: ServerStatus

    private var subscriptions = Set<AnyCancellable>()

    init(server: Server) {
        self.server = server

        name = server.name

        status = server.status
        server.publisher(for: \.status)
            .receive(on: RunLoop.main)
            .assign(to: \.status, on: self)
            .store(in: &subscriptions)

        server.outputHandler = outputHandler
    }

    func start() {
        Task {
            await server.start()
        }
    }

    func clearTerminal() {
        terminalView.clear()
    }

    private func outputHandler(_ data: Data) {
        if let data = String(data: data, encoding: .isoLatin1)?
            .replacingOccurrences(of: "\n", with: "\r\n")
            .data(using: .isoLatin1) {
            terminalView.appendBuffer(data)
        }
    }
}
