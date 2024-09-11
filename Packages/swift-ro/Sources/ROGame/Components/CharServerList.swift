//
//  CharServerList.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RONetwork
import SwiftUI

struct CharServerList: View {
    var charServers: [CharServerInfo]

    @Environment(\.gameSession) private var gameSession

    var body: some View {
        ZStack {
            ROImage("win_service")

            ForEach(charServers, id: \.name) { charServer in
                Text(charServer.name)
            }

            VStack {
                Spacer()

                HStack(spacing: 3) {
                    Spacer()

                    ROButton("btn_ok") {
                        gameSession.selectCharServer(charServers[0])
                    }

                    ROButton("btn_cancel") {
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
    CharServerList(charServers: [])
}
