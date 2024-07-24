//
//  ServerCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import rAthenaLogin
import SwiftUI

struct ServerCell: View {
    var server: ObservableServer

    var body: some View {
        LabeledContent {
            Text(server.status.localizedStringResource)
                .font(.footnote)
        } label: {
            Label(server.name, systemImage: "terminal")
        }
    }
}

#Preview {
    let server = ObservableServer(server: LoginServer.shared)
    return ServerCell(server: server)
}
