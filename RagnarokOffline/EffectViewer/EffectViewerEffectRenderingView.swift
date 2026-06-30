//
//  EffectViewerEffectRenderingView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import Metal
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokResources
import SwiftUI

struct EffectViewerEffectRenderingView: View {
    var effectID: Int
    var resourceManager: ResourceManager

    var body: some View {
        AsyncContentView {
            try await loadRenderer()
        } content: { renderer in
            MetalViewContainer(renderer: renderer)
        }
    }

    private func loadRenderer() async throws -> EffectViewerEffectRenderer {
        let definitions = EffectTable.definitions(forEffectID: effectID).map { $0.resolved() }

        let device = MTLCreateSystemDefaultDevice()!
        let loader = EffectAssetLoader(resourceManager: resourceManager)
        var assets: [EffectAsset] = []

        for definition in definitions {
            let asset = try await loader.loadAsset(with: definition)
            assets.append(asset)
        }

        let renderer = try EffectViewerEffectRenderer(device: device, assets: assets)
        return renderer
    }
}
