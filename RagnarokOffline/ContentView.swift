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
import ROResources

enum SidebarItem: Hashable {
    case files
    case messages
    case cube
    case loginServer
    case charServer
    case mapServer
    case webServer
    case serverFiles
    case itemDatabase
    case jobDatabase
    case mapDatabase
    case monsterDatabase
    case monsterSummonDatabase
    case petDatabase
    case skillDatabase
    case statusChangeDatabase
}

struct ContentView: View {
    @StateObject private var loginServer = ObservableServer(server: LoginServer.shared)
    @StateObject private var charServer = ObservableServer(server: CharServer.shared)
    @StateObject private var mapServer = ObservableServer(server: MapServer.shared)
    @StateObject private var webServer = ObservableServer(server: WebServer.shared)

    @StateObject private var itemDatabase = ObservableDatabase(mode: .renewal, recordProvider: .item)
    @StateObject private var jobDatabase = ObservableDatabase(mode: .renewal, recordProvider: .job)
    @StateObject private var mapDatabase = ObservableDatabase(mode: .renewal, recordProvider: .map)
    @StateObject private var monsterDatabase = ObservableDatabase(mode: .renewal, recordProvider: .monster)
    @StateObject private var monsterSummonDatabase = ObservableDatabase(mode: .renewal, recordProvider: .monsterSummon)
    @StateObject private var petDatabase = ObservableDatabase(mode: .renewal, recordProvider: .pet)
    @StateObject private var skillDatabase = ObservableDatabase(mode: .renewal, recordProvider: .skill)
    @StateObject private var statusChangeDatabase = ObservableDatabase(mode: .renewal, recordProvider: .statusChange)

    @State private var selectedItem: SidebarItem? = .files
    @State private var isSettingsPresented = false

    var body: some View {
        ResponsiveView {
            TabView {
                NavigationStack {
                    FilesView(title: "Client", directory: .directory(ClientResourceBundle.shared.url))
                }
                .tabItem {
                    Label("Client", systemImage: "folder.fill")
                }

                NavigationStack {
                    serverView
                }
                .tabItem {
                    Label("Server", systemImage: "apple.terminal.fill")
                }

                NavigationStack {
                    databaseView
                }
                .tabItem {
                    Label("Database", systemImage: "tablecells.fill")
                }

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
        } regular: {
            NavigationSplitView {
                sidebar
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
        .task {
            await load()
        }
    }

    private var serverView: some View {
        List {
            NavigationLink(value: SidebarItem.loginServer) {
                LabeledContent {
                    Text(loginServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(loginServer.name, systemImage: "terminal")
                }
            }

            NavigationLink(value: SidebarItem.charServer) {
                LabeledContent {
                    Text(charServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(charServer.name, systemImage: "terminal")
                }
            }

            NavigationLink(value: SidebarItem.mapServer) {
                LabeledContent {
                    Text(mapServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(mapServer.name, systemImage: "terminal")
                }
            }

            NavigationLink(value: SidebarItem.webServer) {
                LabeledContent {
                    Text(webServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(webServer.name, systemImage: "terminal")
                }
            }
        }
        .navigationDestination(for: SidebarItem.self) { item in
            switch item {
            case .loginServer:
                ServerTerminalView(server: loginServer)
            case .charServer:
                ServerTerminalView(server: charServer)
            case .mapServer:
                ServerTerminalView(server: mapServer)
            case .webServer:
                ServerTerminalView(server: webServer)
            default:
                EmptyView()
            }
        }
        .navigationTitle("Server")
    }

    private var databaseView: some View {
        List {
            NavigationLink(value: itemDatabase) {
                Label("Item Database", systemImage: "leaf")
            }
            NavigationLink(value: jobDatabase) {
                Label("Job Database", systemImage: "person")
            }
            NavigationLink(value: mapDatabase) {
                Label("Map Database", systemImage: "map")
            }
            NavigationLink(value: monsterDatabase) {
                Label("Monster Database", systemImage: "pawprint")
            }
            NavigationLink(value: monsterSummonDatabase) {
                Label("Monster Summon Database", systemImage: "pawprint")
            }
            NavigationLink(value: petDatabase) {
                Label("Pet Database", systemImage: "pawprint")
            }
            NavigationLink(value: skillDatabase) {
                Label("Skill Database", systemImage: "arrow.up.heart")
            }
            NavigationLink(value: statusChangeDatabase) {
                Label("Status Change Database", systemImage: "zzz")
            }
        }
        .navigationDestination(for: ObservableDatabase<ItemProvider>.self) { database in
            ItemDatabaseView(database: database)
        }
        .navigationDestination(for: ObservableDatabase<JobProvider>.self) { database in
            JobDatabaseView(database: database)
        }
        .navigationDestination(for: ObservableDatabase<MapProvider>.self) { database in
            MapDatabaseView(database: database)
        }
        .navigationDestination(for: ObservableDatabase<MonsterProvider>.self) { database in
            MonsterDatabaseView(database: database)
        }
        .navigationDestination(for: ObservableDatabase<MonsterSummonProvider>.self) { database in
            MonsterSummonDatabaseView(database: database)
        }
        .navigationDestination(for: ObservableDatabase<PetProvider>.self) { database in
            PetDatabaseView(database: database)
        }
        .navigationDestination(for: ObservableDatabase<SkillProvider>.self) { database in
            SkillDatabaseView(database: database)
        }
        .navigationDestination(for: ObservableDatabase<StatusChangeProvider>.self) { database in
            StatusChangeDatabaseView(database: database)
        }
        .navigationTitle("Database")
    }

    private var sidebar: some View {
        List(selection: $selectedItem) {
            Section("Client") {
                NavigationLink(value: SidebarItem.files) {
                    Label("Files", systemImage: "folder")
                }

                #if DEBUG
                NavigationLink(value: SidebarItem.messages) {
                    Label("Messages", systemImage: "message")
                }

                NavigationLink(value: SidebarItem.cube) {
                    Label("Cube", systemImage: "cube")
                }
                #endif
            }

            Section("Server") {
                NavigationLink(value: SidebarItem.loginServer) {
                    LabeledContent {
                        Text(loginServer.status.description)
                            .font(.footnote)
                    } label: {
                        Label(loginServer.name, systemImage: "terminal")
                    }
                }

                NavigationLink(value: SidebarItem.charServer) {
                    LabeledContent {
                        Text(charServer.status.description)
                            .font(.footnote)
                    } label: {
                        Label(charServer.name, systemImage: "terminal")
                    }
                }

                NavigationLink(value: SidebarItem.mapServer) {
                    LabeledContent {
                        Text(mapServer.status.description)
                            .font(.footnote)
                    } label: {
                        Label(mapServer.name, systemImage: "terminal")
                    }
                }

                NavigationLink(value: SidebarItem.webServer) {
                    LabeledContent {
                        Text(webServer.status.description)
                            .font(.footnote)
                    } label: {
                        Label(webServer.name, systemImage: "terminal")
                    }
                }

                #if DEBUG
                NavigationLink(value: SidebarItem.serverFiles) {
                    Label("Server Files", systemImage: "folder")
                }
                #endif
            }

            Section("Database") {
                NavigationLink(value: SidebarItem.itemDatabase) {
                    Label("Item Database", systemImage: "leaf")
                }
                NavigationLink(value: SidebarItem.jobDatabase) {
                    Label("Job Database", systemImage: "person")
                }
                NavigationLink(value: SidebarItem.monsterDatabase) {
                    Label("Monster Database", systemImage: "pawprint")
                }
                NavigationLink(value: SidebarItem.monsterSummonDatabase) {
                    Label("Monster Summon Database", systemImage: "pawprint")
                }
                NavigationLink(value: SidebarItem.mapDatabase) {
                    Label("Map Database", systemImage: "map")
                }
                NavigationLink(value: SidebarItem.petDatabase) {
                    Label("Pet Database", systemImage: "pawprint")
                }
                NavigationLink(value: SidebarItem.skillDatabase) {
                    Label("Skill Database", systemImage: "arrow.up.heart")
                }
                NavigationLink(value: SidebarItem.statusChangeDatabase) {
                    Label("Status Change Database", systemImage: "zzz")
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
    }

    private func detail(for item: SidebarItem) -> some View {
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
                ItemDatabaseView(database: itemDatabase)
            case .jobDatabase:
                JobDatabaseView(database: jobDatabase)
            case .mapDatabase:
                MapDatabaseView(database: mapDatabase)
            case .monsterDatabase:
                MonsterDatabaseView(database: monsterDatabase)
            case .monsterSummonDatabase:
                MonsterSummonDatabaseView(database: monsterSummonDatabase)
            case .petDatabase:
                PetDatabaseView(database: petDatabase)
            case .skillDatabase:
                SkillDatabaseView(database: skillDatabase)
            case .statusChangeDatabase:
                StatusChangeDatabaseView(database: statusChangeDatabase)
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
