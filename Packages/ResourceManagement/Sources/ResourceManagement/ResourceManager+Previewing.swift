//
//  ResourceManager+Previewing.swift
//  ResourceManagement
//
//  Created by Leon Li on 2025/10/22.
//

import Foundation

extension ResourceManager {
    public static let previewing = ResourceManager(
        localURL: Bundle.main.resourceURL!,
        remoteURL: URL(string: "http://127.0.0.1:8080/client")
    )
}
