//
//  WebServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import rAthenaWeb
import SwiftUI

struct WebServerView: View {
    var webServer: ObservableServer

    var body: some View {
        ServerView(server: webServer)
    }
}

#Preview {
    let webServer = ObservableServer(server: WebServer.shared)
    return WebServerView(webServer: webServer)
}
