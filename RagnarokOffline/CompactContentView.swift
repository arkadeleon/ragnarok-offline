//
//  CompactContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/6.
//

import SwiftUI
import RODatabase

struct CompactContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                FilesView(title: "Client", directory: .directory(ClientResourceBundle.shared.url))
            }
            .tabItem {
                Label("Client", systemImage: "folder.fill")
            }

            NavigationStack {
                ServerView()
            }
            .tabItem {
                Label("Server", systemImage: "apple.terminal.fill")
            }

            NavigationStack {
                DatabaseView()
            }
            .tabItem {
                Label("Database", systemImage: "tablecells.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}

#Preview {
    CompactContentView()
}
