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
        locale: .current,
        localURL: .documentsDirectory,
        remoteURL: URL(string: ClientSettings.shared.remoteClient)
    )
}
