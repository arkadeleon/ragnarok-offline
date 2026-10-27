//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//

import RagnarokDatabase
import SwiftUI

struct SettingsView: View {
    @Environment(SettingsModel.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    Text("About")
                }
            } header: {
                Text("General")
            }

            Section {
                NavigationLink {
                    RemoteClientSettingsView()
                } label: {
                    LabeledContent {
                        Text(settings.isRemoteClientEnabled ? "On" : "Off")
                    } label: {
                        Text("Remote Client")
                    }
                }
            } header: {
                Text("Client")
            }

            Section {
                NavigationLink {
                    ServerConfigurationView(serverConfiguration: serverConfiguration)
                } label: {
                    Text("Server Configuration")
                }

                Toggle(isOn: $settings.automaticallyRestartsServers) {
                    Text("Restart Servers Automatically")
                    Text("Restart previously running servers when returning to the foreground")
                }
            } header: {
                Text("Server")
            }

            Section {
                Picker("Database Mode", selection: $settings.databaseMode) {
                    Text("Pre-Renewal")
                        .tag(DatabaseMode.prerenewal)
                    Text("Renewal")
                        .tag(DatabaseMode.renewal)
                }
            } header: {
                Text("Database")
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
