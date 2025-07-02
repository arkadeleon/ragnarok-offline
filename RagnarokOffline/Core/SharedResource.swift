//
//  SharedResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/8.
//

import Foundation
import ROResources

extension ResourceManager {
    static let shared = ResourceManager(
        localURL: .documentsDirectory,
        remoteURL: URL(string: ClientSettings.shared.remoteClient)
    )
}

extension ScriptManager {
    static let shared = ScriptManager(locale: .current, resourceManager: .shared)
}
