//
//  SettingsModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import Foundation
import Observation

private enum SettingsKey {
    static let serverAddress = "client.server_address"
    static let serverPort = "client.server_port"
}

@MainActor
@Observable
final class SettingsModel {
    @ObservationIgnored
    private let defaults: UserDefaults

    var isRemoteClientEnabled = false

    var serverAddress: String {
        didSet {
            defaults.set(serverAddress, forKey: SettingsKey.serverAddress)
        }
    }

    var serverPort: String {
        didSet {
            defaults.set(serverPort, forKey: SettingsKey.serverPort)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        serverAddress = defaults.string(forKey: SettingsKey.serverAddress) ?? "127.0.0.1"
        serverPort = defaults.string(forKey: SettingsKey.serverPort) ?? "6900"
    }
}
