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
    case grfArchiveEntry(GRFArchive, GRFEntryNode)
}

public actor ResourceManager {
    nonisolated public let localURL: URL
    nonisolated public let remoteURL: URL?
    nonisolated public let cachesURL: URL?

    var resources: [String : ResourcePhase] = [:]

    nonisolated private let localGRFArchives: [GRFArchive]

    public init(localURL: URL, remoteURL: URL? = nil, cachesURL: URL? = nil) {
        self.localURL = localURL
        self.remoteURL = remoteURL
        self.cachesURL = cachesURL

        let dataGRFURL = localURL.appending(path: "data.grf")
        localGRFArchives = [
            GRFArchive(url: dataGRFURL),
        ]
    }

    nonisolated public func locatorOfResource(at path: ResourcePath) async throws -> ResourceLocator {
        let fileURL = localURL.absoluteURL.appending(path: L2K(path))
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            return .url(fileURL)
        }

        let grfPath = GRFPath(components: path.components)
        for grfArchive in localGRFArchives {
            if let entry = await grfArchive.entry(at: grfPath) {
                return .grfArchiveEntry(grfArchive, entry)
            }
        }

        throw ResourceError.resourceNotFound(path)
    }

    nonisolated public func contentsOfResource(at path: ResourcePath) async throws -> Data {
        let fileURL = localURL.absoluteURL.appending(path: L2K(path))
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            let data = try Data(contentsOf: fileURL)
            return data
        }

        let grfPath = GRFPath(components: path.components)
        for grfArchive in localGRFArchives {
            if let entry = await grfArchive.entry(at: grfPath) {
                let data = try await grfArchive.contentsOfEntry(at: entry.path)
                return data
            }
        }

        if let cachesURL {
            let cachedFileURL = cachesURL.absoluteURL.appending(path: L2K(path))
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

            if let cachesURL {
                let cachedFileURL = cachesURL.appending(path: L2K(path))
                try? FileManager.default.createDirectory(at: cachedFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                try? data.write(to: cachedFileURL)
            }

            return data
        }

        throw ResourceError.resourceNotFound(path)
    }
}
