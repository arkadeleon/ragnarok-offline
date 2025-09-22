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
    static let previewing = GameSession(serverAddress: "127.0.0.1", serverPort: "6900", resourceManager: .previewing)
}

extension ResourceManager {
    static let previewing = ResourceManager(
        localURL: Bundle.main.resourceURL!,
        remoteURL: URL(string: "http://127.0.0.1:8080/client")
    )
}
