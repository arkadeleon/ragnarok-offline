//
//  GameView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/5.
//

import RagnarokLocalization
import SwiftUI

public struct GameView: View {
    public var gameSession: GameSession

    @Environment(\.exitGame) private var exitGame

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
                    #if os(visionOS)
                    RealityMapSceneView(scene: scene as! RealityMapScene)
                    #else
                    MetalMapSceneView(scene: scene as! MetalMapScene)
                    #endif
                }
            }
        }
        .overlay(alignment: .center) {
            if gameSession.isDisconnected {
                MessageBoxView(gameSession.context.messageStringTable.localizedMessageString(forID: 2)) {
                    Button("OK") {
                        gameSession.exitSession()
                        exitGame()
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                }
            }
        }
        .environment(gameSession)
        .environment(gameSession.context)
        .onIncrementStatusProperty { sp, amount in
            gameSession.incrementStatusProperty(sp, by: amount)
        }
        .persistentSystemOverlays(.hidden)
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

    public init(gameSession: GameSession) {
        self.gameSession = gameSession
    }
}

#Preview {
    GameView(gameSession: .testing)
}
