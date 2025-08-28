//
//  SettingsModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import Foundation

@Observable
final class SettingsModel {
    @ObservationIgnored
    @SettingsItem("client.remote_client", defaultValue: true) var remoteClient: Bool

    @ObservationIgnored
    @SettingsItem("client.server_address", defaultValue: "127.0.0.1") var serverAddress: String

    @ObservationIgnored
    @SettingsItem("client.server_port", defaultValue: "6900") var serverPort: String

    @ObservationIgnored
    @SettingsItem("client.username", defaultValue: "") var username: String

    @ObservationIgnored
    @SettingsItem("client.password", defaultValue: "") var password: String
}
