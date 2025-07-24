//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//

import rAthenaCommon
import SwiftUI

struct ServerView: View {
    var server: ServerModel

    var body: some View {
        ZStack {
            ConsoleView(messages: server.consoleMessages)

            if server.status == .notStarted {
                Button {
                    Task {
                        try await server.start()
                    }
                } label: {
                    Image(systemName: "play")
                        .font(.system(size: 40))
                        .padding(15)
                }
                .buttonStyle(.bordered)
                #if !os(macOS)
                .buttonBorderShape(.circle)
                #endif
            }
        }
        .background(.background)
        .navigationTitle(server.name)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    Task {
                        await server.stop()
                    }
                } label: {
                    Image(systemName: "stop.fill")
                }
                .disabled(stopDisabled)

                Button {
                    Task {
                        try await server.start()
                    }
                } label: {
                    Image(systemName: "play.fill")
                }
                .disabled(startDisabled)
            }

            ToolbarItem(placement: .primaryAction) {
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
}

#Preview {
    ServerView(server: ServerModel(server: Server()))
}
