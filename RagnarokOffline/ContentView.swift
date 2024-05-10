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
    case jobDatabase
    case mapDatabase
    case monsterDatabase
    case monsterSummonDatabase
    case petDatabase
    case skillDatabase
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ResponsiveView {
            CompactContentView()
        } regular: {
            RegularContentView()
        }
        .task {
            await load()
        }
    }

    private func load() async {
        try? await ResourceBundle.shared.load()
    }
}
