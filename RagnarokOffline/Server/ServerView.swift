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
            if server.status == .stopped {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            try await server.start()
                        }
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
            }

            if server.status == .running {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await server.stop()
                        }
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                }
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
}

#Preview {
    ServerView(server: ServerModel(server: Server()))
}
