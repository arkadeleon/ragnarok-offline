//
//  RagnarokOfflineApp.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaResource

@main
struct RagnarokOfflineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? ResourceBundle.shared.load()
                }
        }
    }
}
