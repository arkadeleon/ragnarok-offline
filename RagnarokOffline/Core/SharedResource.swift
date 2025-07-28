//
//  SharedResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/8.
//

import Foundation
import ROResources

let localClientURL = URL.documentsDirectory
let remoteClientCachesURL = URL.cachesDirectory.appending(path: "com.github.arkadeleon.ragnarok-offline-remote-client")

extension ResourceManager {
    static let shared = ResourceManager(
        localURL: localClientURL,
        remoteURL: URL(string: ClientSettings.shared.remoteClient),
        cachesURL: remoteClientCachesURL
    )
}
