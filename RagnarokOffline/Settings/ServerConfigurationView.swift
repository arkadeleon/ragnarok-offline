//
//  ServerConfigurationView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/8/29.
//

import SwiftUI
import rAthenaResources

struct ServerConfigurationView: View {
    var serverConfiguration: ServerConfiguration

    var body: some View {
        List {
            ForEach(sections, id: \.header) { section in
                Section {
                    Text(section.content)
                        .monospaced()
                        .textSelection(.enabled)
                } header: {
                    Text(section.header)
                }
            }
        }
        .navigationTitle("Server Configuration")
        .toolbarTitleDisplayMode(.inline)
    }

    private var sections: [(header: String, content: String)] {
        let sections: [(String, String?)] = [
            ("atcommands", serverConfiguration.atcommands),
            ("battle_conf", serverConfiguration.battle_conf),
            ("char_conf", serverConfiguration.char_conf),
            ("groups", serverConfiguration.groups),
            ("inter_conf", serverConfiguration.inter_conf),
            ("inter_server", serverConfiguration.inter_server),
            ("log_conf", serverConfiguration.log_conf),
            ("login_conf", serverConfiguration.login_conf),
            ("map_conf", serverConfiguration.map_conf),
            ("packet_conf", serverConfiguration.packet_conf),
            ("script_conf", serverConfiguration.script_conf),
            ("web_conf", serverConfiguration.web_conf),
        ]

        return sections.compactMap { (header, content) in
            guard let content else {
                return nil
            }
            return (header, content)
        }
    }
}

#Preview {
    NavigationStack {
        ServerConfigurationView(serverConfiguration: serverConfiguration)
    }
}
