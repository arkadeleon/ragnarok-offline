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
    private let filesView = FilesView(title: "Files", directory: .directory(ClientResourceBundle.shared.url))

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
                            .navigationTitle("Cube")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Cube", systemImage: "cube")
                    }
                    #endif
                }

                Section("Server") {
                    ForEach(servers, id: \.name) { server in
                        NavigationLink {
                            ServerView(server: server)
                        } label: {
                            Label(server.name, systemImage: "terminal")
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
                        ItemGrid(database: database)
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
                        SkillGrid(database: database)
                    } label: {
                        Label("Skills", systemImage: "arrow.up.heart")
                    }

                    NavigationLink {
                        MapGrid(database: database)
                    } label: {
                        Label("Maps", systemImage: "map")
                    }
                }
            }
            .navigationTitle("Ragnarok Offline")
            .toolbar {
                Menu {
                    Button {
                        Task {
                            async let startLoginServer = RALoginServer.shared.start()
                            async let startCharServer = RACharServer.shared.start()
                            async let startMapServer = RAMapServer.shared.start()
                            async let startWebServer = RAWebServer.shared.start()
                            _ = await (startLoginServer, startCharServer, startMapServer, startWebServer)
                        }
                    } label: {
                        Label("Start All Servers", systemImage: "play")
                    }

                    Button {
                        isSettingsPresented.toggle()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
