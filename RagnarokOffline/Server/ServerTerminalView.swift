//
//  ServerTerminalView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//

import SwiftUI
import rAthenaCommon

struct ServerTerminalView: View {
    var server: ObservableServer

    var body: some View {
        ZStack {
            TerminalViewContainer(terminalView: server.terminalView)

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
