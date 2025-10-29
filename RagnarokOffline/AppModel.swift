//
//  AppModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/3.
//

import Observation
import RagnarokGame
import RagnarokResources
import rAthenaChar
import rAthenaLogin
import rAthenaMap
import rAthenaResources
import rAthenaWeb

let localClientURL = URL.documentsDirectory
let remoteClientURL = URL(string: "http://ragnarokoffline.online/client")
let remoteClientCacheURL = URL.cachesDirectory.appending(path: "com.github.arkadeleon.ragnarok-offline-remote-client")
let serverWorkingDirectoryURL = URL.libraryDirectory.appending(path: "rathena", directoryHint: .isDirectory)

@MainActor
@Observable
final class AppModel {
    let mainWindowID = "Main"

    let settings = SettingsModel()

    let clientLocalDirectory = File(node: .directory(localClientURL), location: .client)
    var clientSyncedDirectory: File?
    let clientCachedDirectory = File(node: .directory(remoteClientCacheURL), location: .client)

    let serverDirectory = File(node: .directory(serverWorkingDirectoryURL), location: .server)
    let loginServer = ServerModel(server: LoginServer.shared)
    let charServer = ServerModel(server: CharServer.shared)
    let mapServer = ServerModel(server: MapServer.shared)
    let webServer = ServerModel(server: WebServer.shared)

    let database = DatabaseModel(mode: .renewal)

    let characterSimulator = CharacterSimulator()

    let chatSession: ChatSession
    let gameSession = GameSession(resourceManager: .shared)

    init() {
        chatSession = ChatSession(
            serverAddress: settings.serverAddress,
            serverPort: settings.serverPort
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
                self.clientSyncedDirectory = File(node: .directory(documentsURL), location: .client)
            }
        }
    }
}

extension ResourceManager {
    static let shared = ResourceManager(
        localURL: localClientURL,
        remoteURL: remoteClientURL,
        remoteCacheURL: remoteClientCacheURL
    )
}
