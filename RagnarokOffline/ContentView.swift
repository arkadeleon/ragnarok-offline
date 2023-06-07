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
                Section("Browse") {
                    NavigationLink {
                        ClientView()
                    } label: {
                        Label("Client", systemImage: "ipad.and.iphone")
                    }
                    NavigationLink {
                        ServersView()
                    } label: {
                        Label("Server", systemImage: "macpro.gen3.server")
                    }
                    NavigationLink {
                        GameView()
                    } label: {
                        Label("Game", systemImage: "xbox.logo")
                    }
                }

                Section("Databases") {
                    NavigationLink {
                        ItemListView()
                    } label: {
                        Label("Item Database", systemImage: "list.bullet.rectangle")
                    }
                    NavigationLink {
                        MonsterListView()
                    } label: {
                        Label("Monster Database", systemImage: "list.bullet.rectangle")
                    }
                    NavigationLink {
                        SkillTreeListView()
                    } label: {
                        Label("Skill Database", systemImage: "list.bullet.rectangle")
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Ragnarok Offline")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
