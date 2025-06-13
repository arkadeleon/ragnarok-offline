//
//  ServerCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import SwiftUI

struct ServerCell: View {
    var server: ServerWrapper

    @State private var status: ServerWrapper.Status

    var body: some View {
        LabeledContent {
            Text(status.localizedStringResource)
                .font(.footnote)
        } label: {
            Label(server.name, systemImage: "terminal")
        }
        .onReceive(server.statusPublisher.receive(on: RunLoop.main)) { status in
            self.status = status
        }
    }

    init(server: ServerWrapper) {
        self.server = server
        _status = State(initialValue: server.status)
    }
}

#Preview {
    ServerCell(server: .login)
}
