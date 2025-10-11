//
//  CharServerListView.swift
//  GameView
//
//  Created by Leon Li on 2024/9/10.
//

import GameCore
import NetworkClient
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

            VStack {
                Spacer()

                HStack(spacing: 3) {
                    Spacer()

                    GameButton("btn_ok.bmp") {
                        gameSession.selectCharServer(charServers[0])
                    }

                    GameButton("btn_cancel.bmp") {
                    }
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 4)
            }
        }
        .frame(width: 280, height: 120)
    }
}

#Preview {
    CharServerListView(charServers: [])
        .padding()
        .environment(GameSession.previewing)
}
