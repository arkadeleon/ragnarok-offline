//
//  ResourceManager+Testing.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2025/7/25.
//

import Foundation
import ROResources

extension ResourceManager {
    static let testing = ResourceManager(
        localURL: Bundle.main.resourceURL!,
        remoteURL: URL(string: "http://127.0.0.1:8080/client")
    )
}
