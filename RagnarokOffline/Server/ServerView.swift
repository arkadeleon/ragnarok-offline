//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//

import SwiftUI

struct ServerView: View {
    var server: ServerWrapper

    @State private var status: ServerWrapper.Status
    @State private var consoleMessages: [AttributedString]

    var body: some View {
        ZStack {
            ConsoleView(messages: consoleMessages)

            if status == .notStarted {
                Button {
                    Task {
                        await server.start()
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
            if status == .stopped {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await server.start()
                        }
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
            }

            if status == .running {
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
        .onReceive(server.statusPublisher.receive(on: RunLoop.main)) { status in
            self.status = status
        }
        .onReceive(server.consoleMessagesPublisher.throttle(for: 0.1, scheduler: RunLoop.main, latest: true)) { consoleMessages in
            self.consoleMessages = consoleMessages
        }
    }

    init(server: ServerWrapper) {
        self.server = server
        _status = State(initialValue: server.status)
        _consoleMessages = State(initialValue: server.consoleMessages)
    }
}

#Preview {
    ServerView(server: .login)
}
