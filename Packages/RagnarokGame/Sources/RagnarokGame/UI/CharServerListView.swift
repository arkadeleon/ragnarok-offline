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
        ZStack {
            GameImage("login_interface/win_service.bmp")

            ForEach(charServers, id: \.name) { charServer in
                Text(charServer.name)
                    .gameText()
                    .frame(width: 260)
                    .background(Color(#colorLiteral(red: 0.8039215686, green: 0.8784313725, blue: 1, alpha: 1)))
            }
            .padding(.top, 17)
            .padding(.bottom, 21)
        }
        .frame(width: 280, height: 120)
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 3) {
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
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    CharServerListView(charServers: [])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
