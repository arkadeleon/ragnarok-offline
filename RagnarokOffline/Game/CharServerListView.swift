//
//  CharServerListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import NetworkClient
import ROGame
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

    init(charServers: [CharServerInfo]) {
        self.charServers = charServers
    }
}

#Preview {
    CharServerListView(charServers: [])
        .padding()
        .environment(GameSession.previewing)
}
