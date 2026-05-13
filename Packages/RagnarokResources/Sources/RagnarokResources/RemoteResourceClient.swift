//
//  RemoteResourceClient.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/5/13.
//

import Foundation

public actor RemoteResourceClient {
    public let url: URL
    public let cacheURL: URL?

    private var isEnabled: Bool

    public init(url: URL, cacheURL: URL? = nil, isEnabled: Bool = true) {
        self.url = url
        self.cacheURL = cacheURL
        self.isEnabled = isEnabled
    }

    func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    public func contentsOfResource(at path: ResourcePath) async throws -> Data {
        guard isEnabled else {
            throw ResourceError.resourceNotFound(path)
        }

        if let cacheURL {
            let cachedFileURL = cacheURL.absoluteURL.appending(path: L2K(path))
            if FileManager.default.fileExists(atPath: cachedFileURL.path(percentEncoded: false)) {
                return try Data(contentsOf: cachedFileURL)
            }
        }

        logger.info("Start downloading resource: \(path)")

        let remoteResourceURL = url.appending(path: path)
        let request = URLRequest(url: remoteResourceURL, cachePolicy: .reloadIgnoringLocalCacheData)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ResourceError.resourceNotFound(path)
        }

        if let cacheURL {
            let cachedFileURL = cacheURL.appending(path: L2K(path))
            try? FileManager.default.createDirectory(at: cachedFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: cachedFileURL)
        }

        return data
    }
}
