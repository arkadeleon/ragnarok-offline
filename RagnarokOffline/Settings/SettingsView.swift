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
            Section {
                Toggle("Remote Client", isOn: $settings.isRemoteClientEnabled)
            } header: {
                Text("Client")
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Game resources are used for database icons and previews, character sprites, and the beta Game Client. When Remote Client is enabled, resources are downloaded from the remote server and cached locally. If you already have client files such as data.grf, you can disable Remote Client and use local files instead.")
                    Text("Remote Client is planned to require a subscription in a future update to help cover server costs. Local client files will continue to work without a subscription.")
                        .foregroundStyle(.orange)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarDoneButton(action: onDone)
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
