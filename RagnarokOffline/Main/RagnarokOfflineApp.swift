//
//  RagnarokOfflineApp.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import ROGame
import SwiftUI

@main
struct RagnarokOfflineApp: App {
    @State private var appModel = AppModel()
    @State private var chatSession = ChatSession()
    @State private var gameSession = GameSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environment(chatSession)
                .environment(gameSession)
        }
    }
}
