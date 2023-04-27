//
//  RagnarokOfflineApp.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

@main
struct RagnarokOfflineApp: App {
    @StateObject private var documentPasteboard = DocumentPasteboard()
    @StateObject private var database = Database()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(documentPasteboard)
                .environmentObject(database)
        }
    }
}
