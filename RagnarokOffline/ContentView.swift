//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import rAthenaResources
import SwiftUI

struct ContentView: View {
    @State private var selectedItem: SidebarItem? = .files

    var body: some View {
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
        .task {
            await load()
        }
    }

    private func load() async {
        try? await ServerResourceBundle.shared.load()
    }
}
