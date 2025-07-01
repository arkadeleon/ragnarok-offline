//
//  ServerCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import rAthenaCommon
import SwiftUI

struct ServerCell: View {
    var server: ServerWrapper

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
    ServerCell(server: ServerWrapper(server: Server()))
}
