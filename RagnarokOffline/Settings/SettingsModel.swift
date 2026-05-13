//
//  SettingsModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import Foundation
import Observation

@MainActor
@Observable
final class SettingsModel {
    @ObservationIgnored
    private let defaults: UserDefaults

    var remoteClient: Bool {
        didSet {
            defaults.set(remoteClient, forKey: Key.remoteClient)
        }
    }

    var serverAddress: String {
        didSet {
            defaults.set(serverAddress, forKey: Key.serverAddress)
        }
    }

    var serverPort: String {
        didSet {
            defaults.set(serverPort, forKey: Key.serverPort)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        remoteClient = defaults.object(forKey: Key.remoteClient) as? Bool ?? true
        serverAddress = defaults.string(forKey: Key.serverAddress) ?? "127.0.0.1"
        serverPort = defaults.string(forKey: Key.serverPort) ?? "6900"
    }
}

private extension SettingsModel {
    enum Key {
        static let remoteClient = "client.remote_client"
        static let serverAddress = "client.server_address"
        static let serverPort = "client.server_port"
    }
}
