//
//  RemoteClientSettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/8/5.
//

import StoreKit
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

                    Group {
                        #if REMOTE_CLIENT_SUBSCRIPTION_FEATURE
                        Text("**Remote Client** is a paid option that provides game resources such as textures, sprites, and models without requiring you to keep a full local client archive on this device.", tableName: "Settings")
                        Text("Hosting and delivering these files requires ongoing expenses for server storage, bandwidth, and maintenance. Contributions from **Remote Client** users help cover these costs and keep core features free for everyone.", tableName: "Settings")
                        Text("When **Remote Client** is active, resources are downloaded from the remote server and cached locally in **Remote Client Files**. If you already have client files such as data.grf, you can use the local client instead.", tableName: "Settings")
                        #else
                        Text("The beta Game Client, database icons and sprites, and tools all need game resources. Turn on **Use Remote Client** to download them from the remote server and cache them in **Remote Client Files**. If you already have local client files such as data.grf, leave it off and use those files instead.", tableName: "Settings")
                        Text("**Remote Client** will require a subscription in a future update to help cover server costs. Local client files will continue to work without a subscription.", tableName: "Settings")
                            .foregroundStyle(.orange)
                        #endif
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical)

                #if REMOTE_CLIENT_SUBSCRIPTION_FEATURE
                NavigationLink {
                    SubscriptionStoreView(groupID: remoteClientSubscriptionGroupID)
                        .storeButton(.hidden, for: .cancellation)
                        .storeButton(.visible, for: .restorePurchases)
                } label: {
                    LabeledContent {
                        if settings.hasActiveRemoteClientSubscription {
                            Text("Active", tableName: "Settings")
                        } else {
                            Text("Inactive", tableName: "Settings")
                        }
                    } label: {
                        Text("Subscription", tableName: "Settings")
                    }
                }

                if settings.hasActiveRemoteClientSubscription {
                    Toggle(isOn: $settings.usesRemoteClient) {
                        Text("Use Remote Client", tableName: "Settings")
                    }
                }
                #else
                Toggle(isOn: $settings.usesRemoteClient) {
                    Text("Use Remote Client", tableName: "Settings")
                }
                #endif
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
