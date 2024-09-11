//
//  GameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import SwiftUI

public struct GameView: View {
    @Environment(\.gameSession) private var gameSession

    public var body: some View {
        ZStack {
            switch gameSession.phase {
            case .login:
                Login()
            case .charServerList(let charServers):
                CharServerList(charServers: charServers)
            case .charSelect(let chars):
                CharSelect(chars: chars)
            case .charMake(let slot):
                CharMake(slot: slot)
            case .map(let mapName):
                Map(mapName: mapName)
            }
        }
    }

    public init() {
    }
}

#Preview {
    GameView()
}
