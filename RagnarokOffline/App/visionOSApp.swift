//
//  visionOSApp.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/2/28.
//

#if os(visionOS)

import RagnarokGame
import SwiftUI

@main
struct visionOSApp: App {
    @State private var appModel = AppModel()
    @State private var immersionStyle: any ImmersionStyle = .full

    var body: some Scene {
        WindowGroup(id: appModel.mainWindowID) {
            ContentView()
                .environment(appModel)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    Task {
                        let backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Pause Servers")
                        await appModel.serverManager.pauseServers()
                        UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task {
                        if appModel.settings.automaticallyResumesServers {
                            try await appModel.serverManager.resumeServers()
                        }
                    }
                }
        }

        ImmersiveSpace(id: GameSession.immersiveSpaceID) {
            GameImmersiveSpaceContent(gameSession: appModel.gameSession)
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
        .defaultWindowPlacement { content, context in
            if let mainWindow = context.windows.first(where: { $0.id == appModel.mainWindowID }) {
                WindowPlacement(.trailing(mainWindow))
            } else {
                WindowPlacement()
            }
        }
    }

    init() {
        configureTips()
    }
}

#endif
