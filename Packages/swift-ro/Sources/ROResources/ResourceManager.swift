//
//  ResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import CoreGraphics
import Foundation
import GRF
import ROCore
import Synchronization

public protocol Resource: Sendable {
}

enum ResourceError: LocalizedError {
    case resourceNotFound(ResourcePath)
    case cannotCreateImage

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let path):
            String(localized: "Resource not found at \(path.components.joined(separator: "/"))")
        case .cannotCreateImage:
            String(localized: "Cannot create image")
        }
    }
}

public enum ResourceLocator: Sendable {
    case url(URL)
    case grfArchiveEntry(GRFArchive, GRFEntryNode)
}

final public class ResourceManager: Sendable {
    public let localURL: URL
    public let remoteURL: URL?

    let tasks = Mutex<[String : Task<any Resource, Never>]>([:])

    private let localGRFArchives: [GRFArchive]

    public init(localURL: URL, remoteURL: URL?) {
        self.localURL = localURL
        self.remoteURL = remoteURL

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
            if let entry = await grfArchive.entry(at: grfPath) {
                return .grfArchiveEntry(grfArchive, entry)
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
            if let entry = await grfArchive.entry(at: grfPath) {
                let data = try await grfArchive.contentsOfEntry(at: entry.path)
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

            let cacheURL = localURL.absoluteURL.appending(path: "Caches").appending(path: L2K(path))
            try? FileManager.default.createDirectory(at: cacheURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: cacheURL)

            return data
        }

        throw ResourceError.resourceNotFound(path)
    }

    public func contentsOfLocalizedResource(at path: ResourcePath, locale: Locale) async throws -> Data {
        let fileURL = localURL.absoluteURL.appending(path: L2K(path))
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            let data = try Data(contentsOf: fileURL)
            return data
        }

        if locale.language.languageCode == .korean {
            let grfPath = GRFPath(components: path.components)
            for grfArchive in localGRFArchives {
                if let entry = await grfArchive.entry(at: grfPath) {
                    let data = try await grfArchive.contentsOfEntry(at: entry.path)
                    return data
                }
            }
        }

        if let remoteURL {
            logger.info("Start downloading resource: \(path)")

            let remoteResourceURL = remoteURL.appending(path: path)
            var request = URLRequest(url: remoteResourceURL, cachePolicy: .reloadIgnoringLocalCacheData)

            let localizations = Bundle.module.localizations
            let preferredLocalization = Bundle.preferredLocalizations(from: localizations, forPreferences: [locale.identifier])[0]
            request.setValue(preferredLocalization, forHTTPHeaderField: "RO-Locale")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw ResourceError.resourceNotFound(path)
            }

            let cacheURL = localURL.absoluteURL.appending(path: "Caches").appending(path: L2K(path))
            try? FileManager.default.createDirectory(at: cacheURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: cacheURL)

            return data
        }

        throw ResourceError.resourceNotFound(path)
    }
}

extension ResourceManager {
    public func image(at path: ResourcePath, removesMagentaPixels: Bool = false) async throws -> CGImage {
        let data = try await contentsOfResource(at: path)

        var image = CGImageCreateWithData(data)
        if removesMagentaPixels {
            image = image?.removingMagentaPixels()
        }

        if let image {
            return image
        } else {
            throw ResourceError.cannotCreateImage
        }
    }

    public func localizedImage(at path: ResourcePath, locale: Locale, removesMagentaPixels: Bool = false) async throws -> CGImage {
        let data = try await contentsOfLocalizedResource(at: path, locale: locale)

        var image = CGImageCreateWithData(data)
        if removesMagentaPixels {
            image = image?.removingMagentaPixels()
        }

        if let image {
            return image
        } else {
            throw ResourceError.cannotCreateImage
        }
    }
}
