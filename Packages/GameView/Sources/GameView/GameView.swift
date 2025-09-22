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

    public var body: some View {
        Group {
            switch gameSession.phase {
            case .login:
                LoginView()
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

    public init(gameSession: GameSession) {
        self.gameSession = gameSession
    }
}

#Preview {
    GameView(gameSession: .previewing)
}
