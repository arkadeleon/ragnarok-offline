//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaResource
import rAthenaDatabase
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb

struct ContentView: View {
    private let filesView = FilesView(title: "Files", directory: .directory(ClientBundle.shared.url))

    private let servers: [RAServer] = [
        RALoginServer.shared,
        RACharServer.shared,
        RAMapServer.shared,
        RAWebServer.shared,
    ]

    private let database = Database.renewal

    @State private var isSettingsPresented = false

    var body: some View {
        NavigationView {
            List {
                Section("Client") {
                    NavigationLink {
                        filesView
                    } label: {
                        Label("Files", systemImage: "folder")
                    }

                    #if DEBUG
                    NavigationLink {
                        GameView()
                            .ignoresSafeArea()
                            .navigationTitle("Game")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Game", systemImage: "gamecontroller")
                    }
                    #endif
                }

                Section("Server") {
                    ForEach(servers, id: \.name) { server in
                        NavigationLink {
                            ServerView(server: server)
                        } label: {
                            Label(server.name, systemImage: "macpro.gen3.server")
                        }
                    }

                    #if DEBUG
                    NavigationLink {
                        FilesView(title: "Server Files", directory: .directory(ResourceBundle.shared.url))
                    } label: {
                        Label("Server Files", systemImage: "folder")
                    }
                    #endif
                }

                Section("Database") {
                    NavigationLink {
                        ItemList(database: database)
                    } label: {
                        Label("Items", systemImage: "leaf")
                    }

                    NavigationLink {
                        MonsterGrid(database: database)
                    } label: {
                        Label("Monsters", systemImage: "pawprint")
                    }

                    NavigationLink {
                        JobGrid(database: database)
                    } label: {
                        Label("Jobs", systemImage: "person")
                    }

                    NavigationLink {
                        SkillList(database: database)
                    } label: {
                        Label("Skills", systemImage: "arrow.up.heart")
                    }

                    NavigationLink {
                        MapList(database: database)
                    } label: {
                        Label("Maps", systemImage: "map")
                    }
                }
            }
            .navigationTitle("Ragnarok Offline")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSettingsPresented.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }

            filesView
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
