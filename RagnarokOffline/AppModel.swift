//
//  AppModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/3.
//

import GameCore
import Observation
import ResourceManagement
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

    let clientLocalDirectory = File(node: .directory(localClientURL))
    var clientSyncedDirectory: File?
    let clientCachedDirectory = File(node: .directory(remoteClientCachesURL))

    let serverDirectory = File(node: .directory(ServerResourceManager.shared.workingDirectoryURL))
    let loginServer = ServerModel(server: LoginServer.shared)
    let charServer = ServerModel(server: CharServer.shared)
    let mapServer = ServerModel(server: MapServer.shared)
    let webServer = ServerModel(server: WebServer.shared)

    let database = DatabaseModel(mode: .renewal)

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

        Task.detached {
            let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)
            guard let containerURL else {
                return
            }

            let documentsURL = containerURL.appending(component: "Documents")
            let dataURL = documentsURL.appending(component: "data")

            try? FileManager.default.createDirectory(at: dataURL, withIntermediateDirectories: true)

            Task { @MainActor in
                self.clientSyncedDirectory = File(node: .directory(documentsURL))
            }
        }
    }
}

extension ResourceManager {
    static let shared = ResourceManager(
        localURL: localClientURL,
        remoteURL: remoteClientURL,
        cachesURL: remoteClientCachesURL
    )
}
