//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsModel.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section {
                NavigationLink {
                    RemoteClientSettingsView()
                } label: {
                    Text("Remote Client")
                }
            } header: {
                Text("Client")
            }

            Section {
                Toggle("Resume Servers Automatically", isOn: $settings.automaticallyResumesServers)
            } header: {
                Text("Server")
            } footer: {
                Text("When enabled, servers that were running before the app entered the background automatically resume when the app returns to the foreground.")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarDoneButton {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(SettingsModel())
}
