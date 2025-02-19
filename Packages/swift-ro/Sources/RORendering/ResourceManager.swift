//
//  ResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import Foundation
import ROFileFormats

enum ResourceError: Error {
    case resourceNotFound
}

final public class ResourceManager {
    public let url: URL

    private let grfs: [GRFReference]

    public init(url: URL) {
        self.url = url

        grfs = [
            GRFReference(url: url.appending(path: "data.grf")),
        ]
    }

    public func spriteResource(at path: ResourcePath) async throws -> SpriteResource {
        let path = ["data", "sprite"] + path

        let actPath = path.appendingPathExtension("act")
        let actData = try contentsOfResource(at: actPath)
        let act = try ACT(data: actData)

        let sprPath = path.appendingPathExtension("spr")
        let sprData = try contentsOfResource(at: sprPath)
        let spr = try SPR(data: sprData)

        let sprite = SpriteResource(act: act, spr: spr)
        return sprite
    }

    private func contentsOfResource(at path: ResourcePath) throws -> Data {
        let fileURL = url.absoluteURL.appending(path: path)
        let filePath = fileURL.path(percentEncoded: false)
        if FileManager.default.fileExists(atPath: filePath) {
            let data = try Data(contentsOf: fileURL)
            return data
        }

        let grfPath = GRF.Path(components: path.components)
        for grf in grfs {
            if grf.entry(at: grfPath) != nil {
                return try grf.contentsOfEntry(at: grfPath)
            }
        }

        throw ResourceError.resourceNotFound
    }
}
