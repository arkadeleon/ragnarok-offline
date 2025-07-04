//
//  GameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import ROGame
import SwiftUI

struct GameView: View {
    @Environment(GameSession.self) private var gameSession

    var body: some View {
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
                ProgressView()
            case .map(let scene):
                MapView(scene: scene)
            }
        }
        .task {
            gameSession.start(resourceManager: .shared)
        }
    }
}

#Preview {
    GameView()
        .environment(GameSession())
}
