//
//  ServerCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import ROServer
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
    let server = ObservableServer(server: .login)
    return ServerCell(server: server)
}
