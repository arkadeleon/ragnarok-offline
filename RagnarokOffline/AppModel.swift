//
//  AppModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/3.
//

import Observation
import ROGame
import ROResources
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb
import rAthenaResources

let localClientURL = URL.documentsDirectory
let remoteClientURL = URL(string: "http://ragnarokoffline.online/client")
let remoteClientCachesURL = URL.cachesDirectory.appending(path: "com.github.arkadeleon.ragnarok-offline-remote-client")

@MainActor
@Observable
final class AppModel {
    let mainWindowID = "Main"

    let settings = SettingsModel()

    let fileSystem = FileSystem()

    let clientDirectory = File(node: .directory(localClientURL))
    let clientCachesDirectory = File(node: .directory(remoteClientCachesURL))

    let serverDirectory = File(node: .directory(ServerResourceManager.shared.workingDirectoryURL))
    let loginServer = ServerModel(server: LoginServer.shared)
    let charServer = ServerModel(server: CharServer.shared)
    let mapServer = ServerModel(server: MapServer.shared)
    let webServer = ServerModel(server: WebServer.shared)

    var itemDatabase = DatabaseModel(mode: .renewal, recordProvider: .item)
    var jobDatabase = DatabaseModel(mode: .renewal, recordProvider: .job)
    var mapDatabase = DatabaseModel(mode: .renewal, recordProvider: .map)
    var monsterDatabase = DatabaseModel(mode: .renewal, recordProvider: .monster)
    var monsterSummonDatabase = DatabaseModel(mode: .renewal, recordProvider: .monsterSummon)
    var petDatabase = DatabaseModel(mode: .renewal, recordProvider: .pet)
    var skillDatabase = DatabaseModel(mode: .renewal, recordProvider: .skill)
    var statusChangeDatabase = DatabaseModel(mode: .renewal, recordProvider: .statusChange)

    let characterSimulator = CharacterSimulator()

    let chatSession: ChatSession
    let gameSession: GameSession

    init() {
        chatSession = ChatSession(
            serverAddress: settings.serverAddress,
            serverPort: settings.serverPort
        )

        gameSession = GameSession(
            serverAddress: settings.serverAddress,
            serverPort: settings.serverPort,
            resourceManager: .shared
        )
    }
}

extension ResourceManager {
    static let shared = ResourceManager(
        localURL: localClientURL,
        remoteURL: remoteClientURL,
        cachesURL: remoteClientCachesURL
    )
}
