//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import SwiftUI
import rAthenaResource

enum MenuItem: Hashable {
    case files
    case messages
    case cube
    case loginServer
    case charServer
    case mapServer
    case webServer
    case serverFiles
    case itemDatabase
    case monsterDatabase
    case jobDatabase
    case skillDatabase
    case mapDatabase
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            RegularContentView()
                .task {
                    await load()
                }
        } else {
            CompactContentView()
                .task {
                    await load()
                }
        }
    }

    private func load() async {
        try? await ResourceBundle.shared.load()
    }
}
