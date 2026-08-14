//
//  MetalMapCompositorContent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/13.
//

#if os(visionOS)

import CompositorServices
import RagnarokRendering
import SwiftUI

public struct MetalMapCompositorContent: ImmersiveSpaceContent {
    private var gameSession: GameSession

    public var body: some ImmersiveSpaceContent {
        CompositorLayer(configuration: MetalMapLayerConfiguration()) { layerRenderer in
            guard let scene = gameSession.mapScene,
                  let layerMapRenderer = MetalMapLayerRenderer(layerRenderer: layerRenderer, scene: scene) else {
                return
            }
            layerMapRenderer.start()
        }
    }

    public init(gameSession: GameSession) {
        self.gameSession = gameSession
    }
}

struct MetalMapLayerConfiguration: CompositorLayerConfiguration {
    func makeConfiguration(
        capabilities: LayerRenderer.Capabilities,
        configuration: inout LayerRenderer.Configuration
    ) {
        // `.shared` puts both eyes in one texture and tells them apart by viewport. That is
        // already how `render(frame:)` draws: one encoder, one `setViewport` per view.
        if capabilities.supportedLayouts(options: []).contains(.shared) {
            configuration.layout = .shared
        }

        configuration.colorFormat = RenderConfiguration.immersive.colorPixelFormat
        configuration.depthFormat = RenderConfiguration.immersive.depthStencilPixelFormat

        // One map cell is one meter, so a map reaches hundreds of meters. Push the far
        // plane out and keep the near plane the compositor asked for, since it rejects
        // anything closer. The far plane comes first: the range is in reverse-Z order.
        configuration.defaultDepthRange = [1000, configuration.defaultDepthRange.y]
    }
}

extension RenderConfiguration {
    /// What the game's immersive space renders into.
    ///
    /// The renderers build their pipeline states when the map scene loads, before there is
    /// a `LayerRenderer` to ask, so the formats are fixed here and the layer is configured
    /// to match. Compositor Services only supports reversed depth.
    public static let immersive = RenderConfiguration(
        // The layer traps on any format outside `LayerRenderer.Capabilities`, and
        // `.bgra8Unorm` is not among them. Every format it does accept is read as linear,
        // so the renderers' sRGB values still need a decode in the fragment shaders.
        colorPixelFormat: .rgba16Float,
        depthStencilPixelFormat: .depth32Float,
        isDepthReversed: true
    )
}

#endif
