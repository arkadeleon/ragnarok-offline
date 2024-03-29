//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var serviceType = ClientSettings.shared.serviceType

    var body: some View {
        let serviceTypeBinding = Binding {
            serviceType
        } set: {
            self.serviceType = $0
            ClientSettings.shared.serviceType = $0
        }

        NavigationView {
            Form {
                Section("Client") {
                    Picker("Service Type", selection: serviceTypeBinding) {
                        ForEach(ClientSettings.ServiceType.allCases, id: \.rawValue) { serviceType in
                            Text(serviceType.description).tag(serviceType)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
