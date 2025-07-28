//
//  StartAllServersButton.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/28.
//

import SwiftUI

struct StartAllServersButton: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        Button {
            Task {
                try await startAllServers()
            }
        } label: {
            Label("Start All Servers", systemImage: "play")
        }
    }

    private func startAllServers() async throws {
        async let startLoginServer = appModel.loginServer.start()
        async let startCharServer = appModel.charServer.start()
        async let startMapServer = appModel.mapServer.start()
        async let startWebServer = appModel.webServer.start()

        _ = try await (startLoginServer, startCharServer, startMapServer, startWebServer)
    }
}
