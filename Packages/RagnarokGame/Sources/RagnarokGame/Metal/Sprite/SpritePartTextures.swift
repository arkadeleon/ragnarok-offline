//
//  SpritePartTextures.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/13.
//

import Metal
import RagnarokFileFormats
import RagnarokRenderers
import RagnarokSprite

final class SpritePartTextures {
    private struct CacheKey: Hashable {
        let resourceID: ObjectIdentifier
        let spriteType: Int32
        let spriteIndex: Int32
    }

    private enum CacheValue {
        case texture(any MTLTexture)
        case missing
    }

    let device: any MTLDevice

    private var cache: [CacheKey : CacheValue] = [:]

    init(device: any MTLDevice) {
        self.device = device
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
