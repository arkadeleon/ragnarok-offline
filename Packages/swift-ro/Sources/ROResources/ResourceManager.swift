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

public enum ResourceLocator {
    case url(URL)
    case grfPath(GRFReference, GRFPath)
}

public actor ResourceManager {
    nonisolated public let baseURL: URL

    private let grfs: [GRFReference]

    public init(baseURL: URL) {
        self.baseURL = baseURL

        let dataGRFURL = baseURL.appending(path: "data.grf")

        if !FileManager.default.fileExists(atPath: dataGRFURL.path()) {
            let data = Data()
            let url = baseURL.appending(path: "Copy data.grf Here")
            do {
                try data.write(to: url)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }
        }

        grfs = [
            GRFReference(url: dataGRFURL),
        ]
    }

    public func resourceExists(at path: ResourcePath) -> Bool {
        do {
            _ = try locatorOfResource(at: path)
            return true
        } catch {
            return false
        }
    }

    public func locatorOfResource(at path: ResourcePath) throws -> ResourceLocator {
        let fileURL = baseURL.absoluteURL.appending(path: path)
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            return .url(fileURL)
        }

        let grfPath = GRFPath(components: path.components)
        for grf in grfs {
            if let _ = grf.entry(at: grfPath) {
                return .grfPath(grf, grfPath)
            }
        }

        #if DEBUG
        if let fileURL = Bundle.main.resourceURL?.appending(path: path),
           FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            return .url(fileURL)
        }
        #endif

        throw ResourceError.resourceNotFound(path)
    }

    public func contentsOfResource(at path: ResourcePath) async throws -> Data {
        let locator = try locatorOfResource(at: path)
        switch locator {
        case .url(let url):
            let data = try Data(contentsOf: url)
            return data
        case .grfPath(let grf, let grfPath):
            let data = try grf.contentsOfEntry(at: grfPath)
            return data
        }
    }

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
}
