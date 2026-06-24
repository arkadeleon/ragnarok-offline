//
//  TestResourceProvider.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/6/24.
//

import Foundation

final class TestResourceProvider: ResourceProvider {
    func contentsOfResource(at path: ResourcePath) async throws -> Data {
        let url = URL(string: "http://127.0.0.1:8080/client")!
        let resourceURL = url.appending(path: path)
        let request = URLRequest(url: resourceURL, cachePolicy: .reloadIgnoringLocalCacheData)
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}

extension ResourceManager {
    public static let testing = ResourceManager(resourceProvider: TestResourceProvider())
}
