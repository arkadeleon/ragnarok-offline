//
//  macOSApp.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/2/28.
//

#if os(macOS)

import RagnarokGame
import SwiftUI

@main
struct macOSApp: App {
    @Environment(\.dismissWindow) private var dismissWindow
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup(id: appModel.mainWindowID) {
            ContentView()
                .environment(appModel)
                .onAppear {
                    appDelegate.appModel = appModel
                }
        }

        WindowGroup("Game", id: appModel.gameSession.windowID, for: GameSession.Configuration.self) { configuration in
            GameView(gameSession: appModel.gameSession) {
                dismissWindow(id: appModel.gameSession.windowID)
            }
            .onAppear {
                if let configuration = configuration.wrappedValue {
                    appModel.gameSession.start(configuration)
                } else {
                    let configuration = GameSession.Configuration(
                        serverAddress: appModel.settings.serverAddress,
                        serverPort: UInt16(appModel.settings.serverPort)!
                    )
                    appModel.gameSession.start(configuration)
                }
            }
            .onDisappear {
                appModel.gameSession.stop()
            }
        }
    }

    init() {
        configureTips()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var appModel: AppModel?

    private var isTerminating = false

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let appModel else {
            return .terminateNow
        }

        guard !isTerminating else {
            return .terminateLater
        }

        isTerminating = true

        Task {
            await appModel.stopAllServers()
            NSApp.reply(toApplicationShouldTerminate: true)
        }

        return .terminateLater
    }
}

#endif
