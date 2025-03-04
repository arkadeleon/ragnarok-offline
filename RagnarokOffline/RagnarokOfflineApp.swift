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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        ActionsComponent.registerComponent()
        SpriteComponent.registerComponent()
    }
}
