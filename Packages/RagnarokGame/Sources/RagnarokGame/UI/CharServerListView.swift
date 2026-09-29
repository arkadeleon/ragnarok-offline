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
                            .foregroundStyle(Color.gameLabel)
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
                Button {
                    if let charServer = charServers.first {
                        gameSession.audioPlayer.playButtonSoundEffect()
                        gameSession.selectCharServer(charServer)
                    }
                } label: {
                    Text("OK", bundle: #bundle)
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
                .disabled(charServers.isEmpty)

                Button {
                    gameSession.exitCurrentPhase()
                } label: {
                    Text("cancel", bundle: #bundle)
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
            }
        }
        .gameWindowTitle(Text("Service Select", bundle: #bundle))
        .frame(width: 280)
    }
}

#Preview {
    CharServerListView(charServers: [])
        .padding()
        .environment(GameSession.testing)
}
