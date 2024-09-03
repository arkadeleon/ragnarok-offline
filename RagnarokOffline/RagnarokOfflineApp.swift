//
//  RagnarokOfflineApp.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import SwiftUI
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb

@main
struct RagnarokOfflineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension EnvironmentValues {
    @Entry var conversation = Conversation()

    @Entry var loginServer = ObservableServer(server: LoginServer.shared)
    @Entry var charServer = ObservableServer(server: CharServer.shared)
    @Entry var mapServer = ObservableServer(server: MapServer.shared)
    @Entry var webServer = ObservableServer(server: WebServer.shared)
}
