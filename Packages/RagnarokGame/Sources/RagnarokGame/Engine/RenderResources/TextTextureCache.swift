//
//  TextTextureCache.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/15.
//

import Metal
import RagnarokRendering

@MainActor
final class TextTextureCache {
    private let device: any MTLDevice

    private var textures: [TextDescriptor : any MTLTexture] = [:]

    init(device: any MTLDevice) {
        self.device = device
    }

    /// Returns a texture for each text that can be drawn, and drops the textures of text that is no longer drawn.
    func synchronize(texts: [TextDescriptor]) -> [TextDescriptor : any MTLTexture] {
        for text in Set(textures.keys).subtracting(texts) {
            textures.removeValue(forKey: text)
        }

        for text in texts where textures[text] == nil {
            textures[text] = MetalTextureFactory.makeTexture(
                from: text.makeImage(),
                device: device,
                label: "text"
            )
        }

        return textures
    }

    func removeAll() {
        textures.removeAll()
    }
}
