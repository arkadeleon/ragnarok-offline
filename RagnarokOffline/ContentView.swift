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
                        .navigationTitle("Client")
                        .navigationBarTitleDisplayMode(.inline)
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

                Section("Database") {
                    NavigationLink {
                        WeaponListView()
                            .navigationTitle("Weapons")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Weapons", systemImage: "list.dash")
                    }
                    NavigationLink {
                        ArmorListView()
                            .navigationTitle("Armors")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Armors", systemImage: "list.dash")
                    }
                    NavigationLink {
                        CardListView()
                            .navigationTitle("Cards")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Cards", systemImage: "list.dash")
                    }
                    NavigationLink {
                        ItemListView()
                            .navigationTitle("Items")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Items", systemImage: "list.dash")
                    }
                    NavigationLink {
                        MonsterListView()
                            .navigationTitle("Monsters")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Monsters", systemImage: "list.dash")
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
