//
//  LocalResourceClient.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/5/13.
//

import Foundation
import RagnarokGRF

final public class LocalResourceClient: Sendable {
    public let url: URL

    private let grfArchives: [GRFArchive]

    public init(url: URL) {
        self.url = url

        let dataGRFURL = url.appending(path: "data.grf")
        grfArchives = [
            GRFArchive(url: dataGRFURL),
        ]
    }

    public func locatorOfResource(at path: ResourcePath) async throws -> ResourceLocator {
        let fileURL = url.absoluteURL.appending(path: L2K(path))
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            return .url(fileURL)
        }

        let grfPath = GRFPath(components: path.components)
        for grfArchive in grfArchives {
            if let entryNode = await grfArchive.entryNode(at: grfPath) {
                return .grfArchiveNode(grfArchive, entryNode)
            }
        }

        throw ResourceError.resourceNotFound(path)
    }

    public func contentsOfResource(at path: ResourcePath) async throws -> Data {
        let fileURL = url.absoluteURL.appending(path: L2K(path))
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            return try Data(contentsOf: fileURL)
        }

        let grfPath = GRFPath(components: path.components)
        for grfArchive in grfArchives {
            if let entryNode = await grfArchive.entryNode(at: grfPath) {
                return try await grfArchive.contentsOfEntryNode(at: entryNode.path)
            }
        }

        throw ResourceError.resourceNotFound(path)
    }
}
