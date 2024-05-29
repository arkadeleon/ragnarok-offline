//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//

import SwiftUI
import ROClient

struct SettingsView: View {
    @State private var serviceType = ClientSettings.shared.serviceType
    @State private var itemInfoSource = ClientSettings.shared.itemInfoSource

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
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
