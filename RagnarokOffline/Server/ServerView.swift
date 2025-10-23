//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//

import rAthenaCommon
import rAthenaResources
import SwiftUI

struct ServerView: View {
    var server: ServerModel

    var body: some View {
        ZStack {
            ConsoleView(messages: server.consoleMessages)

            if server.status == .notStarted {
                Button {
                    startServer()
                } label: {
                    Image(systemName: "play")
                        .font(.system(size: 40))
                        .padding(15)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
            }
        }
        .background(.background)
        .navigationTitle(server.name)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    stopServer()
                } label: {
                    Image(systemName: "stop.fill")
                }
                .disabled(stopDisabled)

                Button {
                    startServer()
                } label: {
                    Image(systemName: "play.fill")
                }
                .disabled(startDisabled)
            }

            ToolbarItem {
                Button {
                    server.clearConsole()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }

    private var startDisabled: Bool {
        switch server.status {
        case .notStarted, .stopped: false
        case .starting, .running, .stopping: true
        }
    }

    private var stopDisabled: Bool {
        switch server.status {
        case .notStarted, .starting, .stopping, .stopped: true
        case .running: false
        }
    }

    private func startServer() {
        Task {
            let serverResourceManager = ServerResourceManager()
            try await serverResourceManager.prepareWorkingDirectory(at: serverWorkingDirectoryURL)

            _ = await server.start()
        }
    }

    private func stopServer() {
        Task {
            _ = await server.stop()
        }
    }
}

#Preview {
    ServerView(server: ServerModel(server: Server()))
}
