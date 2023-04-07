//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    ClientView()
                } label: {
                    Label("Client", systemImage: "desktopcomputer")
                }
                NavigationLink {
                    Text("Server")
                        .navigationTitle("Server")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Label("Server", systemImage: "server.rack")
                }

                Section("Databases") {
                    NavigationLink {
                        ItemListView()
                    } label: {
                        Label("Item Database", systemImage: "list.dash")
                    }
                    NavigationLink {
                        MonsterListView()
                    } label: {
                        Label("Monster Database", systemImage: "list.dash")
                    }
                    NavigationLink {
                        SkillTreeListView()
                    } label: {
                        Label("Skill Database", systemImage: "list.dash")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Ragnarok Offline")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
