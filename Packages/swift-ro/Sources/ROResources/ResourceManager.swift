//
//  ResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import Foundation
import ROFileFormats

enum ResourceError: LocalizedError {
    case resourceNotFound(ResourcePath)

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let path):
            String(localized: "Resource not found at: \(path.components.joined(separator: "/"))")
        }
    }
}

public actor ResourceManager {
    public static let `default` = ResourceManager(baseURL: .documentsDirectory)

    nonisolated public let baseURL: URL

    private let grfs: [GRFReference]

    init(baseURL: URL) {
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

    public func contentsOfResource(at path: ResourcePath) async throws -> Data {
        let fileURL = baseURL.absoluteURL.appending(path: path)
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            let data = try Data(contentsOf: fileURL)
            return data
        }

        let grfPath = GRFPath(components: path.components)
        for grf in grfs {
            if let _ = grf.entry(at: grfPath) {
                return try grf.contentsOfEntry(at: grfPath)
            }
        }

        #if DEBUG
        if let fileURL = Bundle.main.resourceURL?.appending(path: path),
           FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            let data = try Data(contentsOf: fileURL)
            return data
        }
        #endif

        throw ResourceError.resourceNotFound(path)
    }
}
