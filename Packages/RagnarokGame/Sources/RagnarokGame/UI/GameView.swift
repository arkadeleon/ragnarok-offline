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
            switch gameSession.stage {
            case .login(let loginPhase):
                LoginStageView(loginPhase: loginPhase)
            case .play(let playSession):
                Group {
                    switch playSession.mapPhase {
                    case .connecting, .loading:
                        MapLoadingView(progress: loadingProgress(for: playSession.mapPhase))
                    case .loaded(let runtime):
                        MapSceneView(runtime: runtime)
                    }
                }
                .environment(playSession)
            }
        }
        .overlay(alignment: .center) {
            ZStack {
                ForEach(gameSession.errorMessages.reversed()) { errorMessage in
                    MessageBoxView(errorMessage.content) {
                        // btn_ok.bmp
                        Button {
                            errorMessage.performAction(in: gameSession)
                        } label: {
                            Text("OK", bundle: #bundle)
                        }
                        .buttonStyle(.game)
                        .frame(width: 42, height: 20)
                    }
                }
            }
            .offset(y: -120)
        }
        .overlay(alignment: .center) {
            if gameSession.isDisconnected {
                MessageBoxView(gameSession.context.messageStringTable.localizedMessageString(forID: 2)) {
                    // btn_ok.bmp
                    Button {
                        gameSession.exitSession()
                        exitGame()
                    } label: {
                        Text("OK", bundle: #bundle)
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                }
            }
        }
        .environment(gameSession)
        .environment(gameSession.context)
        .onIncrementStatusProperty { sp, amount in
            gameSession.playSession?.incrementStatusProperty(sp, by: amount)
        }
        .onUpgradeSkillLevel { skillID in
            gameSession.playSession?.upgradeSkillLevel(skillID: skillID)
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

    private func loadingProgress(for mapPhase: PlaySession.MapPhase) -> Progress {
        if case .loading(let progress) = mapPhase {
            progress
        } else {
            Progress()
        }
    }
}

#Preview {
    GameView(gameSession: .testing)
}
