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
                    Label {
                        Text("Server Not Started", tableName: "Server")
                    } icon: {
                        Image(systemName: "server.rack")
                    }
                } description: {
                    Text("Tap Start to run the server", tableName: "Server")
                } actions: {
                    Button {
                        Task {
                            try await appModel.startServer(server)
                        }
                    } label: {
                        Label {
                            Text("Start Server", tableName: "Server")
                        } icon: {
                            Image(systemName: "play.fill")
                        }
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    }
                    .adaptiveProminentButtonStyle()
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(.background)
        .navigationTitle(server.nameResource)
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

            #if os(iOS) || os(macOS)
            if #available(iOS 26.0, macOS 26.0, *) {
                ToolbarSpacer()
            }
            #endif

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
