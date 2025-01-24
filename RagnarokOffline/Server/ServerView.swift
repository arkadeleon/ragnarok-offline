//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//

import SwiftUI

struct ServerView: View {
    var server: ObservableServer

    var body: some View {
        ZStack {
            ConsoleView(messages: server.messages)

            if server.status == .notStarted {
                Button {
                    server.start()
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
                        server.start()
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
            }

            if server.status == .running {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        server.stop()
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
