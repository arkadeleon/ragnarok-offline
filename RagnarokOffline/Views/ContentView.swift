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
    @StateObject private var loginServer = ObservableServer(server: LoginServer.shared)
    @StateObject private var charServer = ObservableServer(server: CharServer.shared)
    @StateObject private var mapServer = ObservableServer(server: MapServer.shared)
    @StateObject private var webServer = ObservableServer(server: WebServer.shared)

    private let database = Database.renewal
    @StateObject private var itemDatabase = ObservableItemDatabase(database: .renewal)
    @StateObject private var monsterDatabase = ObservableMonsterDatabase(database: .renewal)

    private let filesView = FilesView(title: "Files", directory: .directory(ClientResourceBundle.shared.url))

    @State private var status: AsyncContentStatus<Void> = .notYetLoaded
    @State private var isSettingsPresented = false

    var body: some View {
        AsyncContentView(status: status) {
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
                            ConnectionTestView()
                        } label: {
                            Label("Connection Test", systemImage: "link")
                        }

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
                        NavigationLink {
                            ServerView(server: loginServer)
                        } label: {
                            LabeledContent {
                                Text(loginServer.status.description)
                                    .font(.footnote)
                            } label: {
                                Label(loginServer.name, systemImage: "terminal")
                            }
                        }

                        NavigationLink {
                            ServerView(server: charServer)
                        } label: {
                            LabeledContent {
                                Text(charServer.status.description)
                                    .font(.footnote)
                            } label: {
                                Label(charServer.name, systemImage: "terminal")
                            }
                        }

                        NavigationLink {
                            ServerView(server: mapServer)
                        } label: {
                            LabeledContent {
                                Text(mapServer.status.description)
                                    .font(.footnote)
                            } label: {
                                Label(mapServer.name, systemImage: "terminal")
                            }
                        }

                        NavigationLink {
                            ServerView(server: webServer)
                        } label: {
                            LabeledContent {
                                Text(webServer.status.description)
                                    .font(.footnote)
                            } label: {
                                Label(webServer.name, systemImage: "terminal")
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
                            ItemDatabaseView(itemDatabase: itemDatabase)
                        } label: {
                            Label("Item Database", systemImage: "leaf")
                        }

                        NavigationLink {
                            MonsterDatabaseView(monsterDatabase: monsterDatabase)
                        } label: {
                            Label("Monster Database", systemImage: "pawprint")
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
                            startAllServers()
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
        .task {
            await load()
        }
    }

    private func load() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        do {
            try await ResourceBundle.shared.load()
            status = .loaded(())
        } catch {
            status = .failed(error)
        }
    }

    private func startAllServers() {
        loginServer.start()
        charServer.start()
        mapServer.start()
        webServer.start()
    }
}
