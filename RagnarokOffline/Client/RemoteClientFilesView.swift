//
//  RemoteClientFilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/18.
//

import SwiftUI

struct RemoteClientFilesView: View {
    var directory: File

    @Environment(SettingsModel.self) private var settings

    var body: some View {
        if settings.isRemoteClientEnabled {
            FilesView("Remote Client Files", directory: directory)
        } else {
            ContentUnavailableView {
                Label("Remote Client Inactive", systemImage: "folder.fill")
            } description: {
                Text("Activate **Remote Client** in **Settings** to browse cached files")
            }
            .navigationTitle("Remote Client Files")
        }
    }
}
