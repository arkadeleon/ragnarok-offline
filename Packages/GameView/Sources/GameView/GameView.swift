//
//  GameView.swift
//  GameView
//
//  Created by Leon Li on 2024/9/5.
//

import GameCore
import SwiftUI

public struct GameView: View {
    public var gameSession: GameSession
    public var onExit: () -> Void

    public var body: some View {
        Group {
            switch gameSession.phase {
            case .login:
                LoginView(onExit: onExit)
            case .charServerList(let charServers):
                CharServerListView(charServers: charServers)
            case .charSelect(let chars):
                CharSelectView(chars: chars)
            case .charMake(let slot):
                CharMakeView(slot: slot)
            case .mapLoading:
                MapLoadingView(progress: 0)
            case .map(let scene):
                MapView(scene: scene)
            }
        }
        .environment(gameSession)
    }

    public init(gameSession: GameSession, onExit: @escaping () -> Void) {
        self.gameSession = gameSession
        self.onExit = onExit
    }
}

#Preview {
    GameView(gameSession: .previewing) {
    }
}
