//
//  GameView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/5.
//

import SwiftUI

public struct GameView: View {
    public var gameSession: GameSession
    public var onExit: () -> Void

    public var body: some View {
        Group {
            switch gameSession.phase {
            case .login(let loginPhase):
                LoginFlowView(loginPhase: loginPhase)
            case .map(let mapPhase):
                switch mapPhase {
                case .loading(let progress):
                    MapLoadingView(progress: progress)
                case .loaded(let scene):
                    MapView(scene: scene)
                }
            }
        }
        .environment(gameSession)
        .environment(\.exitGame, ExitGameAction {
            gameSession.stopAllSessions()
            onExit()
        })
        #if os(iOS)
        .statusBarHidden()
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        #endif
    }

    public init(gameSession: GameSession, onExit: @escaping () -> Void) {
        self.gameSession = gameSession
        self.onExit = onExit
    }
}

#Preview {
    GameView(gameSession: .testing) {
    }
}
