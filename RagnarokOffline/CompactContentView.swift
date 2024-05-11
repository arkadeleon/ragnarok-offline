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

    @StateObject private var itemDatabase = ObservableDatabase(mode: .renewal, recordProvider: .item)
    @StateObject private var jobDatabase = ObservableDatabase(mode: .renewal, recordProvider: .job)
    @StateObject private var mapDatabase = ObservableDatabase(mode: .renewal, recordProvider: .map)
    @StateObject private var monsterDatabase = ObservableDatabase(mode: .renewal, recordProvider: .monster)
    @StateObject private var monsterSummonDatabase = ObservableDatabase(mode: .renewal, recordProvider: .monsterSummon)
    @StateObject private var petDatabase = ObservableDatabase(mode: .renewal, recordProvider: .pet)
    @StateObject private var skillDatabase = ObservableDatabase(mode: .renewal, recordProvider: .skill)

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
