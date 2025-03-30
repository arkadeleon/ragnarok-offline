//
//  GameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import SwiftUI

struct GameView: View {
    var gameSession: GameSession

    var body: some View {
        ZStack {
            switch gameSession.scene {
            case .login:
                LoginView(gameSession: gameSession)
            case .charServerList(let charServers):
                CharServerListView(gameSession: gameSession, charServers: charServers)
            case .charSelect(let chars):
                CharSelectView(gameSession: gameSession, chars: chars)
            case .charMake(let slot):
                CharMakeView(gameSession: gameSession, slot: slot)
            case .mapLoading:
                ProgressView()
            case .map2D(let scene):
                MapView(mapSession: gameSession.mapSession!, scene: scene) {
                    MapView2DContent(scene: scene)
                }
            case .map3D(let scene):
                MapView(mapSession: gameSession.mapSession!, scene: scene) {
                    MapView3DContent(scene: scene)
                }
            }
        }
    }
}

#Preview {
    GameView(gameSession: GameSession())
}
