//
//  RemoteClientSettingsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/8/5.
//

import SwiftUI

struct RemoteClientSettingsView: View {
    @Environment(SettingsModel.self) private var settings

    @State private var remoteClientURLInput = ""

    @FocusState private var isURLFocused: Bool

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "externaldrive.badge.icloud")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(Color.accentColor.gradient, in: RoundedRectangle(cornerRadius: 16))

                    Text("Remote Client", tableName: "Settings")
                        .font(.title)
                        .bold()

                    Text("""
                        **Remote Client** downloads game resources as needed, so you don't have to store the full client on your device. To get started, [build your own remote client](https://github.com/arkadeleon/ragnarok-remote-client) and enter its URL below. Downloaded resources are cached in **Remote Client Files**, so disk usage grows as you use the app.
                        If you prefer to use the app entirely offline, leave **Use Remote Client** off and add your local client files, including data.grf and the BGM folder.
                        You must have the rights or permission to use these files.
                        """, tableName: "Settings")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)

                Toggle(isOn: $settings.isRemoteClientEnabled) {
                    Text("Use Remote Client", tableName: "Settings")
                }

                if settings.isRemoteClientEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Remote Client URL", tableName: "Settings")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField(text: $remoteClientURLInput) {
                            Text(verbatim: "https://example.com")
                        }
                        .focused($isURLFocused)
                        .onSubmit(saveRemoteClientURL)
                        #if !os(macOS)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        #endif
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text("Remote Client", tableName: "Settings"))
        .toolbarTitleDisplayMode(.inline)
        .onAppear {
            remoteClientURLInput = settings.remoteClientURL?.absoluteString ?? ""
        }
        .onDisappear {
            saveRemoteClientURL()
        }
        .onChange(of: isURLFocused) { _, isFocused in
            if !isFocused {
                saveRemoteClientURL()
            }
        }
    }

    private func remoteClientURL(from input: String) -> URL? {
        var input = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if !input.contains("://") {
            input = "https://" + input
        }

        let regex = #/(?i)https?://(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)*\.?|\[[0-9a-f:.]+\])(?::([0-9]{1,5}))?(?:/(?:[^\s?#%]|%[0-9a-f]{2})*)?/#
        guard let match = try? regex.wholeMatch(in: input) else {
            return nil
        }

        if let port = match.1 {
            guard let port = Int(port), (1...65535).contains(port) else {
                return nil
            }
        }

        return URL(string: input)
    }

    private func saveRemoteClientURL() {
        if remoteClientURLInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            settings.remoteClientURL = nil
            return
        }

        guard let url = remoteClientURL(from: remoteClientURLInput) else {
            return
        }

        if settings.remoteClientURL != url {
            settings.remoteClientURL = url
        }

        remoteClientURLInput = url.absoluteString
    }
}

#Preview {
    NavigationStack {
        RemoteClientSettingsView()
    }
    .environment(SettingsModel())
}
