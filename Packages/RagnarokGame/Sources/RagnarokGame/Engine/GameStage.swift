//
//  GameStage.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/7.
//

import Foundation
import RagnarokModels

enum GameStage {
    case login(LoginStage.Phase)
    case map(MapStage.Phase)
}

enum LoginStage {
    enum Phase {
        case login
        case loggingIn
        case charServerList(_ charServers: [CharServerInfo])
        case connectingCharServer(_ charServer: CharServerInfo)
        case characterSelect(_ characters: [CharacterInfo])
        case characterMake(_ slot: Int)
        case waitingForMapServer(_ slot: Int)
    }
}

enum MapStage {
    enum Phase {
        case loading(_ progress: Progress)
        case loaded(_ scene: MetalMapScene)
    }
}
