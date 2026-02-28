//
//  iOSApp.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/2/28.
//

#if os(iOS)

import SwiftUI

@main
struct iOSApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup(id: appModel.mainWindowID) {
            ContentView()
                .environment(appModel)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    Task {
                        let backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Pause Servers")
                        await appModel.pauseServers()
                        UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task {
                        try await appModel.resumeServers()
                    }
                }
        }
    }

    init() {
        configureTips()
    }
}

#endif
