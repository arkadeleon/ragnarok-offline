//
//  ResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import CoreGraphics
import Foundation
import ROCore
import ROFileFormats

enum ResourceError: Error {
    case resourceNotFound(ResourcePath)
    case cannotCreateResource
}

public actor ResourceManager {
    public static let `default` = ResourceManager(
        baseURL: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    )

    nonisolated public let baseURL: URL

    private let grfs: [GRFReference]

    init(baseURL: URL) {
        self.baseURL = baseURL

        grfs = [
            GRFReference(url: baseURL.appending(path: "data.grf")),
        ]
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
            throw ResourceError.cannotCreateResource
        }
    }

    public func palette(at path: ResourcePath) async throws -> PaletteResource {
        let palPath = path.appendingPathExtension("pal")
        let palData = try await contentsOfResource(at: palPath)
        let pal = try PAL(data: palData)

        let palette = PaletteResource(pal: pal)
        return palette
    }

    public func sprite(at path: ResourcePath) async throws -> SpriteResource {
        let actPath = path.appendingPathExtension("act")
        let actData = try await contentsOfResource(at: actPath)
        let act = try ACT(data: actData)

        let sprPath = path.appendingPathExtension("spr")
        let sprData = try await contentsOfResource(at: sprPath)
        let spr = try SPR(data: sprData)

        let sprite = SpriteResource(act: act, spr: spr)
        return sprite
    }

    private func contentsOfResource(at path: ResourcePath) async throws -> Data {
        let fileURL = baseURL.absoluteURL.appending(path: path)
        if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            let data = try Data(contentsOf: fileURL)
            return data
        }

        let grfPath = GRF.Path(components: path.components)
        for grf in grfs {
            if grf.entry(at: grfPath) != nil {
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
