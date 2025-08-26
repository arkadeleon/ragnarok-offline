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

    #if os(visionOS)
    @State private var immersionStyle: any ImmersionStyle = ProgressiveImmersionStyle(immersion: 0.1...0.5, initialAmount: 0.2)
    #endif

    var body: some Scene {
        WindowGroup(id: appModel.mainWindowID) {
            ContentView()
                .environment(appModel)
                .environment(appModel.fileSystem)
                .environment(chatSession)
                .environment(gameSession)
        }

        #if os(visionOS)
        ImmersiveSpace(id: appModel.gameImmersiveSpaceID) {
            if case .map(let scene) = gameSession.phase {
                MapSceneView(scene: scene)
            }
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive)
        .defaultWindowPlacement { content, context in
            if let mainWindow = context.windows.first(where: { $0.id == appModel.mainWindowID }) {
                WindowPlacement(.trailing(mainWindow))
            } else {
                WindowPlacement()
            }
        }
        #endif
    }
}
