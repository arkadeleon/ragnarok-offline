//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//

import SwiftUI

struct SettingsView: View {
    enum Field: Hashable {
        case serverAddress
        case serverPort
    }

    var onDone: () -> Void

    @State private var serviceType = ClientSettings.shared.serviceType
    @State private var itemInfoSource = ClientSettings.shared.itemInfoSource
    @State private var serverAddress = ClientSettings.shared.serverAddress
    @State private var serverPort = ClientSettings.shared.serverPort

    @FocusState private var focusedField: SettingsView.Field?

    var body: some View {
        let serviceTypeBinding = Binding {
            serviceType
        } set: {
            self.serviceType = $0
            ClientSettings.shared.serviceType = $0
        }

        let itemInfoSourceBinding = Binding {
            itemInfoSource
        } set: {
            self.itemInfoSource = $0
            ClientSettings.shared.itemInfoSource = $0
        }

        Form {
            Section("Client") {
                Picker("Service Type", selection: serviceTypeBinding) {
                    ForEach(ClientSettings.ServiceType.allCases, id: \.rawValue) { serviceType in
                        Text(serviceType.description)
                            .tag(serviceType)
                    }
                }

                Picker("Item Info Source", selection: itemInfoSourceBinding) {
                    ForEach(ClientSettings.ItemInfoSource.allCases, id: \.rawValue) { itemInfoSource in
                        Text(itemInfoSource.description)
                            .tag(itemInfoSource)
                    }
                }

                LabeledContent("Server Address") {
                    TextField("Server Address", text: $serverAddress)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .serverAddress)
                }

                LabeledContent("Server Port") {
                    TextField("Server Port", text: $serverPort)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .serverPort)
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: onDone)
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue == SettingsView.Field.serverAddress {
                let regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
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

    init(onDone: @escaping () -> Void) {
        self.onDone = onDone
    }
}

#Preview {
    SettingsView {
    }
}
