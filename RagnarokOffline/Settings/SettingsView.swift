//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//

import SwiftUI

struct SettingsView: View {
    var onDone: () -> Void

    @State private var serverAddress = ClientSettings.shared.serverAddress
    @State private var serverPort = ClientSettings.shared.serverPort

    private enum Field: Hashable {
        case serverAddress
        case serverPort
    }

    @FocusState private var focusedField: SettingsView.Field?

    var body: some View {
        let remoteClient = Binding {
            ClientSettings.shared.remoteClient
        } set: {
            ClientSettings.shared.remoteClient = $0
        }

        Form {
            Section("Client") {
                Toggle("Remote Client", isOn: remoteClient)
            }

            Section("Game") {
                LabeledContent("Server Address") {
                    TextField(String(), text: $serverAddress)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .serverAddress)
                }

                LabeledContent("Server Port") {
                    TextField(String(), text: $serverPort)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .serverPort)
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    focusedField = nil
                    onDone()
                }
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue == SettingsView.Field.serverAddress {
                let regex = /^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)|[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}|localhost)$/
                if let _ = try? regex.wholeMatch(in: serverAddress) {
                    ClientSettings.shared.serverAddress = serverAddress
                } else {
                    serverAddress = ClientSettings.shared.serverAddress
                }
            }

            if oldValue == SettingsView.Field.serverPort {
                let regex = /^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$/
                if let _ = try? regex.wholeMatch(in: serverPort) {
                    ClientSettings.shared.serverPort = serverPort
                } else {
                    serverPort = ClientSettings.shared.serverPort
                }
            }
        }
    }
}

#Preview {
    SettingsView {
    }
}
