//
//  AppModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/7/3.
//

import Foundation
import Observation
import RagnarokDatabase
import RagnarokGame
import RagnarokResources
import rAthenaCommon

@MainActor
@Observable
final class AppModel {
    let mainWindowID = "Main"

    let settings: SettingsModel

    let resourceProvider: ClientResourceProvider
    let resourceManager: ResourceManager

    let localClientDirectory = File(node: .directory(localClientURL), location: .client)
    let remoteClientCacheDirectory = File(node: .directory(remoteClientCacheURL), location: .client)
    let gameSession: GameSession
    let chatSession: ChatSession

    let serverDirectory = File(node: .directory(serverWorkingDirectoryURL), location: .server)
    let serverManager: ServerManager

    private(set) var database: DatabaseModel

    let characterSimulator: CharacterSimulator
    let skillSimulator: SkillSimulator

    init() {
        settings = SettingsModel()

        resourceProvider = ClientResourceProvider(isRemoteClientEnabled: settings.isRemoteClientEnabled)
        resourceManager = ResourceManager(resourceProvider: resourceProvider)

        gameSession = GameSession(resourceManager: resourceManager)
        chatSession = ChatSession(
            serverAddress: settings.serverAddress,
            serverPort: settings.serverPort
        )

        serverManager = ServerManager(mode: settings.serverMode)

        database = DatabaseModel(mode: settings.databaseMode, resourceManager: resourceManager)

        characterSimulator = CharacterSimulator(resourceManager: resourceManager)
        skillSimulator = SkillSimulator()

        observeRemoteClientSubscription()
        observeServerMode()
        observeDatabaseMode()

        setupHelpFile()
    }

    private func observeRemoteClientSubscription() {
        withObservationTracking {
            _ = settings.isRemoteClientEnabled
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else {
                    return
                }

                self.observeRemoteClientSubscription()

                await self.resourceProvider.remoteProvider.setEnabled(self.settings.isRemoteClientEnabled)
                await self.resourceManager.clearCaches()
            }
        }
    }

    private func observeServerMode() {
        withObservationTracking {
            _ = settings.serverMode
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else {
                    return
                }

                self.observeServerMode()

                await self.serverManager.setMode(self.settings.serverMode)
            }
        }
    }

    private func observeDatabaseMode() {
        withObservationTracking {
            _ = settings.databaseMode
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else {
                    return
                }

                self.observeDatabaseMode()

                self.database = DatabaseModel(mode: self.settings.databaseMode, resourceManager: self.resourceManager)
            }
        }
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
