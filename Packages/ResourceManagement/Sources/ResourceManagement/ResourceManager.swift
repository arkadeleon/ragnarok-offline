//
//  ResourceManager.swift
//  ResourceManagement
//
//  Created by Leon Li on 2025/2/14.
//

import Foundation
import GRF

enum ResourceError: LocalizedError {
    case resourceNotFound(ResourcePath)

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let path):
            String(localized: "Resource not found at \(path.components.joined(separator: "/"))")
        }
    }
}

public enum ResourceLocator: Sendable {
    case url(URL)
    case grfArchiveNode(GRFArchive, GRFNode)
}

final public class ResourceManager: Sendable {
    public let localURL: URL
    public let remoteURL: URL?
    public let remoteCacheURL: URL?

    let cache = ResourceCache()

    private let localGRFArchives: [GRFArchive]

    public init(localURL: URL, remoteURL: URL? = nil, remoteCacheURL: URL? = nil) {
        self.localURL = localURL
        self.remoteURL = remoteURL
        self.remoteCacheURL = remoteCacheURL

        let dataGRFURL = localURL.appending(path: "data.grf")
        localGRFArchives = [
            GRFArchive(url: dataGRFURL),
        ]
    }

    public func locatorOfResource(at path: ResourcePath) async throws -> ResourceLocator {
        let fileURL = localURL.absoluteURL.appending(path: L2K(path))
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            return .url(fileURL)
        }

        let grfPath = GRFPath(components: path.components)
        for grfArchive in localGRFArchives {
            if let entryNode = await grfArchive.entryNode(at: grfPath) {
                return .grfArchiveNode(grfArchive, entryNode)
            }
        }

        throw ResourceError.resourceNotFound(path)
    }

    public func contentsOfResource(at path: ResourcePath) async throws -> Data {
        let fileURL = localURL.absoluteURL.appending(path: L2K(path))
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            let data = try Data(contentsOf: fileURL)
            return data
        }

        let grfPath = GRFPath(components: path.components)
        for grfArchive in localGRFArchives {
            if let entryNode = await grfArchive.entryNode(at: grfPath) {
                let data = try await grfArchive.contentsOfEntryNode(at: entryNode.path)
                return data
            }
        }

        if let remoteCacheURL {
            let cachedFileURL = remoteCacheURL.absoluteURL.appending(path: L2K(path))
            if FileManager.default.fileExists(atPath: cachedFileURL.path(percentEncoded: false)) {
                let data = try Data(contentsOf: cachedFileURL)
                return data
            }
        }

        if let remoteURL {
            logger.info("Start downloading resource: \(path)")

            let remoteResourceURL = remoteURL.appending(path: path)
            let request = URLRequest(url: remoteResourceURL, cachePolicy: .reloadIgnoringLocalCacheData)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw ResourceError.resourceNotFound(path)
            }

            if let remoteCacheURL {
                let cachedFileURL = remoteCacheURL.appending(path: L2K(path))
                try? FileManager.default.createDirectory(at: cachedFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                try? data.write(to: cachedFileURL)
            }

            return data
        }

        throw ResourceError.resourceNotFound(path)
    }
}
