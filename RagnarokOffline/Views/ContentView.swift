//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb

struct ContentView: View {
    private let filesView = FilesView(file: .directory(ClientBundle.shared.url))

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
                            .ignoresSafeArea()
                            .navigationTitle("Files")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Files", systemImage: "folder")
                    }

//                    NavigationLink {
//                        GameView()
//                            .ignoresSafeArea()
//                            .navigationTitle("Game")
//                            .navigationBarTitleDisplayMode(.inline)
//                    } label: {
//                        Label("Game", systemImage: "gamecontroller")
//                    }
                }

                Section("Server") {
                    ForEach(servers, id: \.name) { server in
                        NavigationLink {
                            ServerView(server: server)
                        } label: {
                            Label(server.name, systemImage: "macpro.gen3.server")
                        }
                    }
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
                .ignoresSafeArea()
                .navigationTitle("Files")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
