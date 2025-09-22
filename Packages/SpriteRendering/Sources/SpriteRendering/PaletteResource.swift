//
//  PaletteResource.swift
//  SpriteRendering
//
//  Created by Leon Li on 2025/2/21.
//

import FileFormats
import ResourceManagement

final public class PaletteResource: Sendable {
    let pal: PAL

    init(pal: PAL) {
        self.pal = pal
    }
}

extension ResourceManager {
    nonisolated public func palette(at path: ResourcePath) async throws -> PaletteResource {
        let palPath = path.appendingPathExtension("pal")
        let palData = try await contentsOfResource(at: palPath)
        let pal = try PAL(data: palData)

        let palette = PaletteResource(pal: pal)
        return palette
    }
}
