//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//

import SwiftUI
import rAthenaCommon

struct ServerView: View {
    @ObservedObject var server: ObservableServer

    var body: some View {
        ZStack {
            SwiftUITerminalView(terminalView: server.terminalView)
                .ignoresSafeArea(edges: .bottom)

            if server.status == .notStarted {
                Button {
                    server.start()
                } label: {
                    Image(systemName: "play")
                        .font(.system(size: 40))
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
        }
        .navigationTitle(server.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Clear entire display: ^[[2J
                    // Position cursor on top line: ^[[1;1H
                    let escape = "\u{001B}"
                    server.terminalView.feed(text: escape + "[2J" + escape + "[1;1H")
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
