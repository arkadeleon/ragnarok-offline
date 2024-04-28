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
    enum Item: Hashable {
        case files
        case messages
        case cube
        case loginServer
        case charServer
        case mapServer
        case webServer
        case serverFiles
        case itemDatabase
        case monsterDatabase
        case jobDatabase
        case skillDatabase
        case mapDatabase
    }

    @State private var selectedItem: Item? = .files
    @State private var isSettingsPresented = false

    @StateObject private var loginServer = ObservableServer(server: LoginServer.shared)
    @StateObject private var charServer = ObservableServer(server: CharServer.shared)
    @StateObject private var mapServer = ObservableServer(server: MapServer.shared)
    @StateObject private var webServer = ObservableServer(server: WebServer.shared)

    @StateObject private var itemDatabase = ObservableItemDatabase(database: .renewal)
    @StateObject private var monsterDatabase = ObservableMonsterDatabase(database: .renewal)
    @StateObject private var jobDatabase = ObservableJobDatabase(database: .renewal)
    @StateObject private var skillDatabase = ObservableSkillDatabase(database: .renewal)
    @StateObject private var mapDatabase = ObservableMapDatabase(database: .renewal)

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                List(selection: $selectedItem) {
                    clientSection
                    serverSection
                    databaseSection
                }
                .navigationTitle("Ragnarok Offline")
                .toolbar {
                    moreMenu
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
            .task {
                await load()
            }
        } else {
            NavigationStack {
                List {
                    clientSection
                    serverSection
                    databaseSection
                }
                .navigationDestination(for: Item.self) { item in
                    detail(for: item)
                        #if !os(macOS)
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                }
                .navigationTitle("Ragnarok Offline")
                .toolbar {
                    moreMenu
                }
            }
            .task {
                await load()
            }
        }
    }

    private var clientSection: some View {
        Section("Client") {
            NavigationLink(value: Item.files) {
                Label("Files", systemImage: "folder")
            }

            #if DEBUG
            NavigationLink(value: Item.messages) {
                Label("Messages", systemImage: "message")
            }

            NavigationLink(value: Item.cube) {
                Label("Cube", systemImage: "cube")
            }
            #endif
        }
    }

    private var serverSection: some View {
        Section("Server") {
            NavigationLink(value: Item.loginServer) {
                LabeledContent {
                    Text(loginServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(loginServer.name, systemImage: "terminal")
                }
            }

            NavigationLink(value: Item.charServer) {
                LabeledContent {
                    Text(charServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(charServer.name, systemImage: "terminal")
                }
            }

            NavigationLink(value: Item.mapServer) {
                LabeledContent {
                    Text(mapServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(mapServer.name, systemImage: "terminal")
                }
            }

            NavigationLink(value: Item.webServer) {
                LabeledContent {
                    Text(webServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(webServer.name, systemImage: "terminal")
                }
            }

            #if DEBUG
            NavigationLink(value: Item.serverFiles) {
                Label("Server Files", systemImage: "folder")
            }
            #endif
        }
    }

    private var databaseSection: some View {
        Section("Database") {
            NavigationLink(value: Item.itemDatabase) {
                Label("Item Database", systemImage: "leaf")
            }

            NavigationLink(value: Item.monsterDatabase) {
                Label("Monster Database", systemImage: "pawprint")
            }

            NavigationLink(value: Item.jobDatabase) {
                Label("Job Database", systemImage: "person")
            }

            NavigationLink(value: Item.skillDatabase) {
                Label("Skill Database", systemImage: "arrow.up.heart")
            }

            NavigationLink(value: Item.mapDatabase) {
                Label("Map Database", systemImage: "map")
            }
        }
    }

    private var moreMenu: some View {
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
            SettingsView()
        }
    }

    private func detail(for item: Item) -> some View {
        ZStack {
            switch item {
            case .files:
                FilesView(title: "Files", directory: .directory(ClientResourceBundle.shared.url))
            case .messages:
                MessagesView()
            case .cube:
                GameView()
            case .loginServer:
                ServerView(server: loginServer)
            case .charServer:
                ServerView(server: charServer)
            case .mapServer:
                ServerView(server: mapServer)
            case .webServer:
                ServerView(server: webServer)
            case .serverFiles:
                FilesView(title: "Server Files", directory: .directory(ResourceBundle.shared.url))
            case .itemDatabase:
                ItemDatabaseView(itemDatabase: itemDatabase)
            case .monsterDatabase:
                MonsterDatabaseView(monsterDatabase: monsterDatabase)
            case .jobDatabase:
                JobDatabaseView(jobDatabase: jobDatabase)
            case .skillDatabase:
                SkillDatabaseView(skillDatabase: skillDatabase)
            case .mapDatabase:
                MapDatabaseView(mapDatabase: mapDatabase)
            }
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
