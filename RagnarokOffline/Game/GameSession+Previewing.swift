//
//  GameSession+Previewing.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/8/28.
//

import GameCore

extension GameSession {
    static let previewing = GameSession(serverAddress: "127.0.0.1", serverPort: "6900", resourceManager: .shared)
}
