//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State private var serviceType = ClientSettings.shared.serviceType

    var body: some View {
        let serviceTypeBinding = Binding {
            serviceType
        } set: {
            self.serviceType = $0
            ClientSettings.shared.serviceType = $0
        }

        return NavigationView {
            Form {
                Section("Client") {
                    Picker("Service Type", selection: serviceTypeBinding) {
                        ForEach(ClientSettings.ServiceType.allCases, id: \.rawValue) { serviceType in
                            Text(serviceType.rawValue).tag(serviceType)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
