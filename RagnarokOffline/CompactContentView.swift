//
//  CompactContentView.swift
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

struct CompactContentView: View {
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
    }

    private var serverView: some View {
        List {
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
        }
        .navigationDestination(for: MenuItem.self) { item in
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
            NavigationLink(value: MenuItem.itemDatabase) {
                Label("Item Database", systemImage: "leaf")
            }

            NavigationLink(value: MenuItem.jobDatabase) {
                Label("Job Database", systemImage: "person")
            }

            NavigationLink(value: MenuItem.mapDatabase) {
                Label("Map Database", systemImage: "map")
            }

            NavigationLink(value: MenuItem.monsterDatabase) {
                Label("Monster Database", systemImage: "pawprint")
            }

            NavigationLink(value: MenuItem.monsterSummonDatabase) {
                Label("Monster Summon Database", systemImage: "pawprint")
            }

            NavigationLink(value: MenuItem.petDatabase) {
                Label("Pet Database", systemImage: "pawprint")
            }

            NavigationLink(value: MenuItem.skillDatabase) {
                Label("Skill Database", systemImage: "arrow.up.heart")
            }
        }
        .navigationDestination(for: MenuItem.self) { item in
            switch item {
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
            default:
                EmptyView()
            }
        }
        .navigationTitle("Database")
    }
}

#Preview {
    CompactContentView()
}
