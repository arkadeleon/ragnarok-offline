//
//  SettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/26.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State private var textEncoding = ClientSettings.shared.textEncoding

    var body: some View {
        let textEncodingBinding = Binding {
            textEncoding
        } set: {
            self.textEncoding = $0
            ClientSettings.shared.textEncoding = $0
        }

        return NavigationView {
            Form {
                Section("Client") {
                    Picker("Text Encoding", selection: textEncodingBinding) {
                        ForEach(TextEncoding.allCases, id: \.rawValue) { textEncoding in
                            Text(textEncoding.rawValue).tag(textEncoding)
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
