//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//

import StoreKit
import SwiftUI

struct SettingsView: View {
    var onDone: () -> Void

    @Environment(SettingsModel.self) private var settings

    @State private var isRemoteClientSubscriptionPresented = false

    var body: some View {
        Form {
            Section {
                Button {
                    isRemoteClientSubscriptionPresented.toggle()
                } label: {
                    LabeledContent {
                        Text(settings.isRemoteClientEnabled ? "Active" : "Inactive")
                    } label: {
                        Text("Remote Client")
                    }
                }
            } header: {
                Text("Client")
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("**Remote Client** is a paid option that provides game resources such as textures, sprites, and models without requiring you to keep a full local client archive on this device.")
                    Text("Hosting and delivering these files requires ongoing expenses for server storage, bandwidth, and maintenance. Contributions from **Remote Client** users help cover these costs and keep core features free for everyone.")
                    Text("When **Remote Client** is active, resources are downloaded from the remote server and cached locally in **Remote Client Files**. If you already have client files such as data.grf, you can use the local client instead.")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarDoneButton(action: onDone)
        }
        .sheet(isPresented: $isRemoteClientSubscriptionPresented) {
            SubscriptionStoreView(groupID: remoteClientSubscriptionGroupID)
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
