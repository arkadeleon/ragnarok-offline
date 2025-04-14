//
//  GameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/5.
//

import RONetwork
import ROPackets
import SwiftUI

struct GameView: View {
    var gameSession: GameSession

    var body: some View {
        ZStack {
            switch gameSession.scene {
            case .login:
                LoginView(onLogin: login)
            case .charServerList(let charServers):
                CharServerListView(charServers: charServers, onSelectCharServer: selectCharServer)
            case .charSelect(let chars):
                CharSelectView(chars: chars, onSelectChar: selectChar, onMakeChar: makeChar)
            case .charMake(let slot):
                CharMakeView(slot: slot, onMakeChar: makeChar)
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

    private func login(username: String, password: String) {
        gameSession.login(username: username, password: password)
    }

    private func selectCharServer(charServer: CharServerInfo) {
        gameSession.selectCharServer(charServer)
    }

    private func selectChar(char: CharInfo) {
        gameSession.charSession?.selectChar(slot: char.slot)
    }

    private func makeChar(slot: UInt8) {
        gameSession.scene = .charMake(slot)
    }

    private func makeChar(char: CharInfo) {
        gameSession.charSession?.makeChar(char: char)
    }
}

#Preview {
    GameView(gameSession: GameSession())
}
