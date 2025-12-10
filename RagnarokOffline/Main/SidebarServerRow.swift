//
//  SidebarServerRow.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import rAthenaCommon
import SwiftUI

struct SidebarServerRow: View {
    var server: ServerModel

    var body: some View {
        HStack {
            Label {
                Text(server.name)
            } icon: {
                SidebarIcon(name: "server.rack", color: .gray)
            }

            Spacer()

            Text(server.status.localizedStringResource)
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }
    }
}

#Preview {
    SidebarServerRow(server: ServerModel(server: Server()))
}
