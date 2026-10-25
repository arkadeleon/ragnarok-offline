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

                Toggle("Resume Servers Automatically", isOn: $settings.automaticallyResumesServers)
            } header: {
                Text("Server")
            } footer: {
                Text("When enabled, servers that were running before the app entered the background automatically resume when the app returns to the foreground.")
            }

            Section {
                Picker("Mode", selection: $settings.databaseMode) {
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
