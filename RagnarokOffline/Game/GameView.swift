//
//  GameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import SwiftUI

struct GameView: View {
    @Environment(\.gameSession) private var gameSession

    var body: some View {
        ZStack {
            switch gameSession.phase {
            case .login:
                LoginView()
            case .charServerList:
                CharServerListView(charServers: gameSession.loginSession?.charServers ?? [])
            case .charSelect:
                CharSelectView(chars: gameSession.charSession?.chars ?? [])
            case .charMake(let slot):
                CharMakeView(slot: slot)
            case .map:
                if let scene = gameSession.mapScene {
                    MapView(scene: scene)
                } else {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    GameView()
}
