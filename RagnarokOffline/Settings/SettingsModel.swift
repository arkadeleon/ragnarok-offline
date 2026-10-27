//
//  SettingsModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import Foundation
import Observation
import RagnarokDatabase
import StoreKit

let remoteClientSubscriptionGroupID = "22133104"

private enum SettingsKey {
    static let usesRemoteClient = "client.uses_remote_client"
    static let serverAddress = "client.server_address"
    static let serverPort = "client.server_port"
    static let automaticallyRestartsServers = "server.automatically_restarts_servers"
    static let databaseMode = "database.mode"
}

@MainActor
@Observable
final class SettingsModel {
    @ObservationIgnored private let defaults: UserDefaults

    private(set) var hasActiveRemoteClientSubscription = false
    var usesRemoteClient: Bool {
        didSet {
            defaults.set(usesRemoteClient, forKey: SettingsKey.usesRemoteClient)
        }
    }

    var isRemoteClientEnabled: Bool {
        #if REMOTE_CLIENT_SUBSCRIPTION_FEATURE
        hasActiveRemoteClientSubscription && usesRemoteClient
        #else
        usesRemoteClient
        #endif
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

    @ObservationIgnored private var subscriptionStatusTask: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        usesRemoteClient = defaults.object(forKey: SettingsKey.usesRemoteClient) as? Bool ?? true
        serverAddress = defaults.string(forKey: SettingsKey.serverAddress) ?? "127.0.0.1"
        serverPort = defaults.string(forKey: SettingsKey.serverPort) ?? "6900"
        automaticallyRestartsServers = defaults.bool(forKey: SettingsKey.automaticallyRestartsServers)
        databaseMode = defaults.string(forKey: SettingsKey.databaseMode).flatMap(DatabaseMode.init) ?? .renewal

        #if REMOTE_CLIENT_SUBSCRIPTION_FEATURE
        subscriptionStatusTask = Task { [weak self] in
            if let status = try? await Product.SubscriptionInfo.status(for: remoteClientSubscriptionGroupID) {
                self?.hasActiveRemoteClientSubscription = status.contains(where: { $0.state != .revoked && $0.state != .expired })
            }

            for await (groupID, status) in Product.SubscriptionInfo.Status.all where groupID == remoteClientSubscriptionGroupID {
                self?.hasActiveRemoteClientSubscription = status.contains(where: { $0.state != .revoked && $0.state != .expired })
            }
        }
        #endif
    }

    deinit {
        #if REMOTE_CLIENT_SUBSCRIPTION_FEATURE
        subscriptionStatusTask?.cancel()
        #endif
    }
}
