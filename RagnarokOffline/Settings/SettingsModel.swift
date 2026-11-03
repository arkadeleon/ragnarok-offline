//
//  SettingsModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import Foundation
import Observation
import RagnarokDatabase
import rAthenaCommon

private enum SettingsKey {
    static let isRemoteClientEnabled = "client.is_remote_client_enabled"
    static let remoteClientURL = "client.remote_client_url"
    static let serverAddress = "client.server_address"
    static let serverPort = "client.server_port"

    static let serverMode = "server.mode"
    static let automaticallyRestartsServers = "server.automatically_restarts_servers"

    static let databaseMode = "database.mode"
}

@MainActor
@Observable
final class SettingsModel {
    @ObservationIgnored private let defaults: UserDefaults

    var isRemoteClientEnabled: Bool {
        didSet {
            defaults.set(isRemoteClientEnabled, forKey: SettingsKey.isRemoteClientEnabled)
        }
    }

    var remoteClientURL: URL? {
        didSet {
            defaults.set(remoteClientURL?.absoluteString, forKey: SettingsKey.remoteClientURL)
        }
    }

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

    var serverMode: ServerMode {
        didSet {
            defaults.set(serverMode.rawValue, forKey: SettingsKey.serverMode)
        }
    }

    var automaticallyRestartsServers: Bool {
        didSet {
            defaults.set(automaticallyRestartsServers, forKey: SettingsKey.automaticallyRestartsServers)
        }
    }

    var databaseMode: DatabaseMode {
        didSet {
            defaults.set(databaseMode.rawValue, forKey: SettingsKey.databaseMode)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        isRemoteClientEnabled = defaults.object(forKey: SettingsKey.isRemoteClientEnabled) as? Bool ?? false
        remoteClientURL = defaults.string(forKey: SettingsKey.remoteClientURL).flatMap(URL.init(string:))
        serverAddress = defaults.string(forKey: SettingsKey.serverAddress) ?? "127.0.0.1"
        serverPort = defaults.string(forKey: SettingsKey.serverPort) ?? "6900"

        serverMode = (defaults.object(forKey: SettingsKey.serverMode) as? Int).flatMap(ServerMode.init) ?? .renewal
        automaticallyRestartsServers = defaults.bool(forKey: SettingsKey.automaticallyRestartsServers)

        databaseMode = defaults.string(forKey: SettingsKey.databaseMode).flatMap(DatabaseMode.init) ?? .renewal
    }
}
