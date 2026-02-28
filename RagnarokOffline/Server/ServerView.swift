//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//

import SwiftUI

struct ServerView: View {
    var server: ServerModel

    @Environment(AppModel.self) private var appModel

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

    var body: some View {
        ZStack {
            ConsoleView(messages: server.consoleMessages)

            if server.status == .notStarted {
                ContentUnavailableView {
                    Label("Server Not Started", systemImage: "server.rack")
                } description: {
                    Text("Tap Start to run the server")
                } actions: {
                    Button {
                        Task {
                            try await appModel.startServer(server)
                        }
                    } label: {
                        Label("Start Server", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .background(.background)
        .navigationTitle(server.name)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    Task {
                        await appModel.stopServer(server)
                    }
                } label: {
                    Image(systemName: "stop.fill")
                }
                .disabled(stopDisabled)

                Button {
                    Task {
                        try await appModel.startServer(server)
                    }
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
}

#Preview {
    let appModel = AppModel()

    ServerView(server: appModel.loginServer)
        .environment(appModel)
}
