//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//

import RagnarokDatabase
import rAthenaCommon
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SettingsModel.self) private var settings

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section {
                NavigationLink {
                    PatronView()
                        .environment(settings.patron)
                } label: {
                    if settings.patron.hasActiveSubscription {
                        Text("Patron", tableName: "Settings")
                    } else {
                        Text("Become a Patron", tableName: "Settings")
                    }
                }
            } footer: {
                Text("Support RagOff and get early access to new features.", tableName: "Settings")
            }

            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    Text("About", tableName: "Settings")
                }

                NavigationLink {
                    StorageView()
                } label: {
                    Text("Storage", tableName: "Settings")
                }
            } header: {
                Text("General", tableName: "Settings")
            }

            Section {
                NavigationLink {
                    RemoteClientSettingsView()
                } label: {
                    LabeledContent {
                        if settings.isRemoteClientEnabled {
                            Text("On", tableName: "Settings")
                        } else {
                            Text("Off", tableName: "Settings")
                        }
                    } label: {
                        Text("Remote Client", tableName: "Settings")
                    }
                }
            } header: {
                Text("Client", tableName: "Settings")
            }

            Section {
                Picker(selection: $settings.serverMode) {
                    Text("Pre-Renewal", tableName: "Settings")
                        .tag(ServerMode.prerenewal)
                    Text("Renewal", tableName: "Settings")
                        .tag(ServerMode.renewal)
                } label: {
                    HStack {
                        Text("Server Mode", tableName: "Settings")

                        if !settings.patron.hasActiveSubscription {
                            PatronBadgeView()
                        }
                    }
                }
                .disabled(!settings.patron.hasActiveSubscription)

                NavigationLink {
                    ServerConfigurationView(serverConfiguration: serverConfiguration)
                } label: {
                    Text("Server Configuration", tableName: "Settings")
                }

                Toggle(isOn: $settings.automaticallyRestartsServers) {
                    Text("Restart Servers Automatically", tableName: "Settings")
                    Text("Restart previously running servers when returning to the foreground", tableName: "Settings")
                }
            } header: {
                Text("Server", tableName: "Settings")
            }

            Section {
                Picker(selection: $settings.databaseMode) {
                    Text("Pre-Renewal", tableName: "Settings")
                        .tag(DatabaseMode.prerenewal)
                    Text("Renewal", tableName: "Settings")
                        .tag(DatabaseMode.renewal)
                } label: {
                    Text("Database Mode", tableName: "Settings")
                }
            } header: {
                Text("Database", tableName: "Settings")
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text("Settings", tableName: "Settings"))
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarCloseButton {
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
