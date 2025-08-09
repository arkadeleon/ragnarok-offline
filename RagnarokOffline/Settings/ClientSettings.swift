//
//  ClientSettings.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import Foundation

class ClientSettings {
    static let shared = ClientSettings()

    @SettingsItem("client.remote_client", defaultValue: "http://ragnarokoffline.online/client") var remoteClient: String

    @SettingsItem("client.server_address", defaultValue: "127.0.0.1") var serverAddress: String
    @SettingsItem("client.server_port", defaultValue: "6900") var serverPort: String
    @SettingsItem("client.username", defaultValue: "") var username: String
    @SettingsItem("client.password", defaultValue: "") var password: String
}
