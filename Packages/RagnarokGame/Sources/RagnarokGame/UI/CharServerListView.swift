//
//  CharServerListView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/10.
//

import RagnarokModels
import SwiftUI

struct CharServerListView: View {
    var charServers: [CharServerInfo]

    @Environment(GameSession.self) private var gameSession

    var body: some View {
        GameWindow {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(charServers, id: \.name) { charServer in
                        Text(charServer.name)
                            .font(.game())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 2)
                            .background(Color(#colorLiteral(red: 0.8039215686, green: 0.8784313725, blue: 1, alpha: 1)))
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .frame(height: 75)
        } bottomBar: {
            GameBottomBar {
                Button("OK") {
                    if let charServer = charServers.first {
                        gameSession.loginAudioPlayer.playButtonSound()
                        gameSession.selectCharServer(charServer)
                    }
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
                .disabled(charServers.isEmpty)

                Button("cancel") {
                    gameSession.exitCurrentPhase()
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
            }
        }
        .frame(width: 280)
    }
}

#Preview {
    CharServerListView(charServers: [])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
