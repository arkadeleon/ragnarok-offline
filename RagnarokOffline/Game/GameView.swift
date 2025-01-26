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
            switch gameSession.phase {
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
            case .map(let mapName, let gat, let gnd, let position):
                MapView(mapSession: gameSession.mapSession!, mapName: mapName, gat: gat, gnd: gnd, position: position)
            }
        }
    }
}

#Preview {
    GameView(gameSession: GameSession())
}
