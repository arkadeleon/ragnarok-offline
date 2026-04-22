//
//  SpritePartTextures.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/13.
//

import Metal
import RagnarokFileFormats
import RagnarokMetalRendering
import RagnarokSprite

@MainActor
final class SpritePartTextures {
    struct CacheKey: Hashable {
        let resourceID: ObjectIdentifier
        let spriteType: Int32
        let spriteIndex: Int32
    }

    private enum CacheValue {
        case texture(any MTLTexture)
        case missing
    }

    let device: any MTLDevice
    let composedSprite: ComposedSprite

    private var cache: [CacheKey : CacheValue] = [:]

    init(device: any MTLDevice, composedSprite: ComposedSprite) {
        self.device = device
        self.composedSprite = composedSprite
    }

    func texture(for layer: ACT.Layer, resource: SpriteResource, label: String) -> (any MTLTexture)? {
        let key = CacheKey(
            resourceID: ObjectIdentifier(resource),
            spriteType: layer.spriteType,
            spriteIndex: layer.spriteIndex
        )

        if let value = cache[key] {
            switch value {
            case .texture(let texture):
                return texture
            case .missing:
                return nil
            }
        }

        guard let image = resource.image(for: layer),
              let texture = MetalTextureFactory.makeTexture(from: image, device: device, label: label) else {
            cache[key] = .missing
            return nil
        }

        cache[key] = .texture(texture)
        return texture
    }
}
