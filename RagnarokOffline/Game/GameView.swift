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
            case .charServerList(let charServers):
                CharServerListView(charServers: charServers)
            case .charSelect(let chars):
                CharSelectView(chars: chars)
            case .charMake(let slot):
                CharMakeView(slot: slot)
            case .map:
                if let map = gameSession.map {
                    MapView(map: map)
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
