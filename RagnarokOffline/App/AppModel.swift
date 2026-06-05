//
//  AppModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/3.
//

import Foundation
import Observation
import RagnarokGame
import RagnarokResources

let localClientURL = URL.documentsDirectory
let remoteClientURL = URL(string: "http://ragnarokoffline.online/client")!
let remoteClientCacheURL = URL.cachesDirectory.appending(path: "com.github.arkadeleon.ragnarok-offline-remote-client")
let remoteClientSubscriptionGroupID = "22133104"

@MainActor
@Observable
final class AppModel {
    let mainWindowID = "Main"

    let settings: SettingsModel
    let resourceManager: ResourceManager

    let localClientDirectory = File(node: .directory(localClientURL), location: .client)
    let remoteClientCacheDirectory = File(node: .directory(remoteClientCacheURL), location: .client)
    let gameSession: GameSession
    let chatSession: ChatSession

    let serverDirectory = File(node: .directory(serverWorkingDirectoryURL), location: .server)
    let serverManager = ServerManager()

    let database: DatabaseModel

    let characterSimulator: CharacterSimulator
    let skillSimulator: SkillSimulator

    init() {
        let settings = SettingsModel()

        let localClient = LocalResourceClient(url: localClientURL)
        let remoteClient = RemoteResourceClient(
            url: remoteClientURL,
            cacheURL: remoteClientCacheURL,
            isEnabled: settings.isRemoteClientEnabled
        )
        let resourceManager = ResourceManager(
            localClient: localClient,
            remoteClient: remoteClient
        )

        self.settings = settings
        self.resourceManager = resourceManager

        gameSession = GameSession(resourceManager: resourceManager)
        chatSession = ChatSession(
            serverAddress: settings.serverAddress,
            serverPort: settings.serverPort
        )

        database = DatabaseModel(mode: .renewal, resourceManager: resourceManager)

        characterSimulator = CharacterSimulator(resourceManager: resourceManager)
        skillSimulator = SkillSimulator()

        setupHelpFile()
    }

    private func setupHelpFile() {
        let helpFileURL = localClientURL.appending(component: "HELP.md")
        guard !FileManager.default.fileExists(atPath: helpFileURL.path) else {
            return
        }
        guard let bundleURL = Bundle.main.url(forResource: "HELP", withExtension: "md") else {
            return
        }
        try? FileManager.default.copyItem(at: bundleURL, to: helpFileURL)
    }
}
