//
//  CharServerListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import ROGame
import SwiftUI

struct CharServerListView: View {
    var gameSession: GameSession
    var charServers: [CharServerInfo]

    var body: some View {
        ZStack {
            GameImage("login_interface/win_service.bmp")

            ForEach(charServers, id: \.name) { charServer in
                Text(charServer.name)
                    .font(.system(size: 12))
            }

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
    CharServerListView(gameSession: GameSession(), charServers: [])
}
