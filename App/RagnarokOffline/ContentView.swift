//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import SwiftUI
import rAthenaResource
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb
import RODatabase

struct ContentView: View {
    @StateObject private var loginServer = ObservableServer(server: LoginServer.shared)
    @StateObject private var charServer = ObservableServer(server: CharServer.shared)
    @StateObject private var mapServer = ObservableServer(server: MapServer.shared)
    @StateObject private var webServer = ObservableServer(server: WebServer.shared)

    @StateObject private var itemDatabase = ObservableItemDatabase(database: .renewal)
    @StateObject private var monsterDatabase = ObservableMonsterDatabase(database: .renewal)
    @StateObject private var jobDatabase = ObservableJobDatabase(database: .renewal)
    @StateObject private var skillDatabase = ObservableSkillDatabase(database: .renewal)
    @StateObject private var mapDatabase = ObservableMapDatabase(database: .renewal)

    private let filesView = FilesView(title: "Files", directory: .directory(ClientResourceBundle.shared.url))

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
                        JobDatabaseView(jobDatabase: jobDatabase)
                    } label: {
                        Label("Job Database", systemImage: "person")
                    }

                    NavigationLink {
                        SkillDatabaseView(skillDatabase: skillDatabase)
                    } label: {
                        Label("Skill Database", systemImage: "arrow.up.heart")
                    }

                    NavigationLink {
                        MapDatabaseView(mapDatabase: mapDatabase)
                    } label: {
                        Label("Map Database", systemImage: "map")
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

            filesView
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
        .task {
            await load()
        }
    }

    private func load() async {
        try? await ResourceBundle.shared.load()
    }

    private func startAllServers() {
        loginServer.start()
        charServer.start()
        mapServer.start()
        webServer.start()
    }
}
