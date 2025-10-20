//
//  GameSession+Previewing.swift
//  GameView
//
//  Created by Leon Li on 2025/8/28.
//

import Foundation
import GameCore
import ResourceManagement

extension GameSession {
    static let previewing: GameSession = {
        let gameSession = GameSession(resourceManager: .previewing)

        let configuration = GameSession.Configuration(serverAddress: "127.0.0.1", serverPort: "6900")
        gameSession.start(configuration)

        return gameSession
    }()
}

extension ResourceManager {
    static let previewing = ResourceManager(
        localURL: Bundle.main.resourceURL!,
        remoteURL: URL(string: "http://127.0.0.1:8080/client")
    )
}
