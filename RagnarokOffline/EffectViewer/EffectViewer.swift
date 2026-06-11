//
//  EffectViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/3/14.
//

import MetalKit
import RagnarokFileFormats
import RagnarokRenderAssets
import RagnarokRenderers
import RagnarokResources
import SwiftUI

struct EffectViewer: View {
    var resourceManager: ResourceManager

    var body: some View {
        AsyncContentView {
            try await loadSTR(named: "thunderstorm.str")
        } content: { renderer in
            MetalViewContainer(renderer: renderer)
        }
    }

    private func loadSTR(named name: String) async throws -> STRFilePreviewRenderer {
        let path = ResourcePath.effectDirectory.appending(name)
        let data = try await resourceManager.contentsOfResource(at: path)
        let str = try STR(data: data)
        let effect = STREffect(str: str)

        let device = MTLCreateSystemDefaultDevice()!
        let textureLoader = MTKTextureLoader(device: device)
        var textures: [String : any MTLTexture] = [:]

        for frame in effect.frames {
            for sprite in frame.sprites {
                let textureName = sprite.textureName
                if let _ = textures[textureName] {
                    continue
                }

                let texturePath = path.removingLastComponent().appending(subpath: textureName)
                guard let data = try? await resourceManager.contentsOfResource(at: texturePath) else {
                    continue
                }

                if let texture = textureLoader.newTexture(bmpData: data) {
                    textures[textureName] = texture
                }
            }
        }

        let renderer = try STRFilePreviewRenderer(device: device, effect: effect, textures: textures)
        return renderer
    }
}
