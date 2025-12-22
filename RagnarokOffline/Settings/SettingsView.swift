//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//

import SwiftUI

struct SettingsView: View {
    var onDone: () -> Void

    @Environment(SettingsModel.self) private var settings

    var body: some View {
        let remoteClient = Binding {
            settings.remoteClient
        } set: {
            settings.remoteClient = $0
        }

        Form {
            Section("Client") {
                Toggle("Remote Client", isOn: remoteClient)
            }
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark", action: onDone)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView {
        }
    }
    .environment(SettingsModel())
}
