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

final class ResourceManager: @unchecked Sendable {
    public static let `default` = ResourceManager()

    public let baseURL: URL

    let grfs: [GRFReference]

    init() {
        baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        grfs = [
            GRFReference(url: baseURL.appending(path: "data.grf")),
        ]
    }

    func spriteResource(at path: ResourcePath) async throws -> SpriteResource {
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
        let path = GRF.Path(components: path.components)
        for grf in grfs {
            if grf.entry(at: path) != nil {
                return try grf.contentsOfEntry(at: path)
            }
        }
        throw ResourceError.resourceNotFound
    }
}
