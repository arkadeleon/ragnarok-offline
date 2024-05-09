//
//  RegularContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/6.
//

import SwiftUI
import rAthenaResource
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb
import ROResources

struct RegularContentView: View {
    @State private var selectedItem: MenuItem? = .files
    @State private var isSettingsPresented = false

    @StateObject private var loginServer = ObservableServer(server: LoginServer.shared)
    @StateObject private var charServer = ObservableServer(server: CharServer.shared)
    @StateObject private var mapServer = ObservableServer(server: MapServer.shared)
    @StateObject private var webServer = ObservableServer(server: WebServer.shared)

    @StateObject private var itemDatabase = ObservableItemDatabase(database: .renewal)
    @StateObject private var jobDatabase = ObservableJobDatabase(database: .renewal)
    @StateObject private var mapDatabase = ObservableMapDatabase(database: .renewal)
    @StateObject private var monsterDatabase = ObservableMonsterDatabase(mode: .renewal)
    @StateObject private var monsterSummonDatabase = ObservableMonsterSummonDatabase(mode: .renewal)
    @StateObject private var petDatabase = ObservablePetDatabase(mode: .renewal)
    @StateObject private var skillDatabase = ObservableSkillDatabase(database: .renewal)

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                Section("Client") {
                    NavigationLink(value: MenuItem.files) {
                        Label("Files", systemImage: "folder")
                    }

                    #if DEBUG
                    NavigationLink(value: MenuItem.messages) {
                        Label("Messages", systemImage: "message")
                    }

                    NavigationLink(value: MenuItem.cube) {
                        Label("Cube", systemImage: "cube")
                    }
                    #endif
                }

                Section("Server") {
                    NavigationLink(value: MenuItem.loginServer) {
                        LabeledContent {
                            Text(loginServer.status.description)
                                .font(.footnote)
                        } label: {
                            Label(loginServer.name, systemImage: "terminal")
                        }
                    }

                    NavigationLink(value: MenuItem.charServer) {
                        LabeledContent {
                            Text(charServer.status.description)
                                .font(.footnote)
                        } label: {
                            Label(charServer.name, systemImage: "terminal")
                        }
                    }

                    NavigationLink(value: MenuItem.mapServer) {
                        LabeledContent {
                            Text(mapServer.status.description)
                                .font(.footnote)
                        } label: {
                            Label(mapServer.name, systemImage: "terminal")
                        }
                    }

                    NavigationLink(value: MenuItem.webServer) {
                        LabeledContent {
                            Text(webServer.status.description)
                                .font(.footnote)
                        } label: {
                            Label(webServer.name, systemImage: "terminal")
                        }
                    }

                    #if DEBUG
                    NavigationLink(value: MenuItem.serverFiles) {
                        Label("Server Files", systemImage: "folder")
                    }
                    #endif
                }

                Section("Database") {
                    NavigationLink(value: MenuItem.itemDatabase) {
                        Label("Item Database", systemImage: "leaf")
                    }

                    NavigationLink(value: MenuItem.jobDatabase) {
                        Label("Job Database", systemImage: "person")
                    }

                    NavigationLink(value: MenuItem.monsterDatabase) {
                        Label("Monster Database", systemImage: "pawprint")
                    }

                    NavigationLink(value: MenuItem.monsterSummonDatabase) {
                        Label("Monster Summon Database", systemImage: "pawprint")
                    }

                    NavigationLink(value: MenuItem.mapDatabase) {
                        Label("Map Database", systemImage: "map")
                    }

                    NavigationLink(value: MenuItem.petDatabase) {
                        Label("Pet Database", systemImage: "pawprint")
                    }

                    NavigationLink(value: MenuItem.skillDatabase) {
                        Label("Skill Database", systemImage: "arrow.up.heart")
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
                .sheet(isPresented: $isSettingsPresented) {
                    NavigationStack {
                        SettingsView()
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") {
                                        isSettingsPresented.toggle()
                                    }
                                }
                            }
                    }
                }
            }
        } detail: {
            if let item = selectedItem {
                NavigationStack {
                    detail(for: item)
                        #if !os(macOS)
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                }
            }
        }
    }

    private func detail(for item: MenuItem) -> some View {
        ZStack {
            switch item {
            case .files:
                FilesView(title: "Files", directory: .directory(ClientResourceBundle.shared.url))
            case .messages:
                MessagesView()
            case .cube:
                GameView()
            case .loginServer:
                ServerTerminalView(server: loginServer)
            case .charServer:
                ServerTerminalView(server: charServer)
            case .mapServer:
                ServerTerminalView(server: mapServer)
            case .webServer:
                ServerTerminalView(server: webServer)
            case .serverFiles:
                FilesView(title: "Server Files", directory: .directory(ResourceBundle.shared.url))
            case .itemDatabase:
                ItemDatabaseView(itemDatabase: itemDatabase)
            case .jobDatabase:
                JobDatabaseView(jobDatabase: jobDatabase)
            case .mapDatabase:
                MapDatabaseView(mapDatabase: mapDatabase)
            case .monsterDatabase:
                MonsterDatabaseView(monsterDatabase: monsterDatabase)
            case .monsterSummonDatabase:
                MonsterSummonDatabaseView(monsterSummonDatabase: monsterSummonDatabase)
            case .petDatabase:
                PetDatabaseView(petDatabase: petDatabase)
            case .skillDatabase:
                SkillDatabaseView(skillDatabase: skillDatabase)
            }
        }
    }

    private func startAllServers() {
        loginServer.start()
        charServer.start()
        mapServer.start()
        webServer.start()
    }
}

#Preview {
    RegularContentView()
}
