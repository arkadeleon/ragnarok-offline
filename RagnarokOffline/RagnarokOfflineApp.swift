//
//  RagnarokOfflineApp.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb
import rAthenaResources
import ROResources
import SwiftUI

@main
struct RagnarokOfflineApp: App {
    @State private var clientDirectory = File(node: .directory(ResourceManager.shared.localURL))
    @State private var serverDirectory = File(node: .directory(ServerResourceManager.default.workingDirectoryURL))

    @State private var loginServer = ServerWrapper(server: LoginServer.shared)
    @State private var charServer = ServerWrapper(server: CharServer.shared)
    @State private var mapServer = ServerWrapper(server: MapServer.shared)
    @State private var webServer = ServerWrapper(server: WebServer.shared)

    @State private var itemDatabase = ObservableDatabase(mode: .renewal, recordProvider: .item)
    @State private var jobDatabase = ObservableDatabase(mode: .renewal, recordProvider: .job)
    @State private var mapDatabase = ObservableDatabase(mode: .renewal, recordProvider: .map)
    @State private var monsterDatabase = ObservableDatabase(mode: .renewal, recordProvider: .monster)
    @State private var monsterSummonDatabase = ObservableDatabase(mode: .renewal, recordProvider: .monsterSummon)
    @State private var petDatabase = ObservableDatabase(mode: .renewal, recordProvider: .pet)
    @State private var skillDatabase = ObservableDatabase(mode: .renewal, recordProvider: .skill)
    @State private var statusChangeDatabase = ObservableDatabase(mode: .renewal, recordProvider: .statusChange)

    @State private var chatSession = ChatSession()
    @State private var gameSession = GameSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.clientDirectory, clientDirectory)
                .environment(\.serverDirectory, serverDirectory)
                .environment(\.loginServer, loginServer)
                .environment(\.charServer, charServer)
                .environment(\.mapServer, mapServer)
                .environment(\.webServer, webServer)
                .environment(itemDatabase)
                .environment(jobDatabase)
                .environment(mapDatabase)
                .environment(monsterDatabase)
                .environment(monsterSummonDatabase)
                .environment(petDatabase)
                .environment(skillDatabase)
                .environment(statusChangeDatabase)
                .environment(chatSession)
                .environment(gameSession)
        }
    }
}

extension EnvironmentValues {
    @Entry var clientDirectory: File!
    @Entry var serverDirectory: File!

    @Entry var loginServer: ServerWrapper!
    @Entry var charServer: ServerWrapper!
    @Entry var mapServer: ServerWrapper!
    @Entry var webServer: ServerWrapper!
}
