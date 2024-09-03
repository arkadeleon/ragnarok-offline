//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import SwiftUI
import rAthenaResources

struct ContentView: View {
    @State private var selectedItem: SidebarItem? = .files

    var body: some View {
        AsyncContentView(load: load) {
            ResponsiveView {
                NavigationStack {
                    SidebarView(selection: nil)
                        .navigationDestination(for: SidebarItem.self) { item in
                            DetailView(item: item)
                        }
                }
            } regular: {
                NavigationSplitView {
                    SidebarView(selection: $selectedItem)
                } detail: {
                    if let item = selectedItem {
                        NavigationStack {
                            DetailView(item: item)
                        }
                    }
                }
            }
        }
    }

    private func load() async throws {
        try await ServerResourceBundle.shared.load()
    }
}
