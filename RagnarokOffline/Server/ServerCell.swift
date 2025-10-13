//
//  ServerCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import rAthenaCommon
import SwiftUI

struct ServerCell: View {
    var server: ServerModel

    var body: some View {
        HStack {
            Label(server.name, systemImage: "server.rack")

            Spacer()

            Text(server.status.localizedStringResource)
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }
    }
}

#Preview {
    ServerCell(server: ServerModel(server: Server()))
}
