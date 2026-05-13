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
        @Bindable var settings = settings

        Form {
            Section("Client") {
                Toggle("Remote Client", isOn: $settings.remoteClient)
            }
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarCancelButton(action: onDone)
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
