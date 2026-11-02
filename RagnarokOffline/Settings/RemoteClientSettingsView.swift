//
//  RemoteClientSettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/8/5.
//

import SwiftUI

struct RemoteClientSettingsView: View {
    @Environment(SettingsModel.self) private var settings

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "externaldrive.badge.icloud")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 16))

                    Text("Remote Client", tableName: "Settings")
                        .font(.title)
                        .bold()

                    Text("The beta Game Client, database icons and sprites, and tools all need game resources. Turn on **Use Remote Client** to download them from the remote server and cache them in **Remote Client Files**. If you already have local client files such as data.grf, leave it off and use those files instead.", tableName: "Settings")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)

                Toggle(isOn: $settings.isRemoteClientEnabled) {
                    Text("Use Remote Client", tableName: "Settings")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text("Remote Client", tableName: "Settings"))
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RemoteClientSettingsView()
    }
    .environment(SettingsModel())
}
