//
//  CharServerListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RONetwork
import SwiftUI

struct CharServerListView: View {
    var charServers: [CharServerInfo]
    var onSelectCharServer: (CharServerInfo) -> Void

    var body: some View {
        ZStack {
            GameImage("login_interface/win_service.bmp")

            ForEach(charServers, id: \.name) { charServer in
                GameText(charServer.name)
            }

            VStack {
                Spacer()

                HStack(spacing: 3) {
                    Spacer()

                    GameButton("btn_ok.bmp") {
                        onSelectCharServer(charServers[0])
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

    init(charServers: [CharServerInfo], onSelectCharServer: @escaping (CharServerInfo) -> Void) {
        self.charServers = charServers
        self.onSelectCharServer = onSelectCharServer
    }
}

#Preview {
    CharServerListView(charServers: []) { charServer in
        // Select char server.
    }
    .padding()
}
