//
//  GameSession+Previewing.swift
//  GameCore
//
//  Created by Leon Li on 2025/8/28.
//

import ResourceManagement

extension GameSession {
    public static let previewing: GameSession = {
        let gameSession = GameSession(resourceManager: .previewing)

        let configuration = GameSession.Configuration(serverAddress: "127.0.0.1", serverPort: "6900")
        gameSession.start(configuration)

        return gameSession
    }()
}
