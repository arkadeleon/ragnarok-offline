//
//  CharServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import rAthenaChar
import SwiftUI

struct CharServerView: View {
    var charServer: ObservableServer

    var body: some View {
        ServerView(server: charServer)
    }
}

#Preview {
    let charServer = ObservableServer(server: CharServer.shared)
    return CharServerView(charServer: charServer)
}
