//
//  RagnarokOfflineApp.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import GameCore
import GameView
import SwiftUI
import TipKit

@main
struct RagnarokOfflineApp: App {
    #if os(macOS)
    @Environment(\.dismissWindow) private var dismissWindow
    #endif

    @State private var appModel = AppModel()

    #if os(visionOS)
    @State private var immersionStyle: any ImmersionStyle = ProgressiveImmersionStyle(immersion: 0.1...0.5, initialAmount: 0.2)
    #endif

    var body: some Scene {
        WindowGroup(id: appModel.mainWindowID) {
            ContentView()
                .environment(appModel)
        }

        #if os(macOS)
        WindowGroup("Game", id: appModel.gameSession.windowID, for: GameSession.Configuration.self) { configuration in
            GameView(gameSession: appModel.gameSession) {
                dismissWindow(id: appModel.gameSession.windowID)
            }
            .onAppear {
                if let configuration = configuration.wrappedValue {
                    appModel.gameSession.start(configuration)
                }
            }
            .onDisappear {
                appModel.gameSession.stop()
            }
        }
        #endif

        #if os(visionOS)
        ImmersiveSpace(id: appModel.gameSession.immersiveSpaceID) {
            if case .map(let scene) = appModel.gameSession.phase {
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

    init() {
        do {
            #if DEBUG
            Tips.showAllTipsForTesting()
            #endif

            try Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        } catch {
            logger.warning("TipKit error: \(error)")
        }
    }
}
