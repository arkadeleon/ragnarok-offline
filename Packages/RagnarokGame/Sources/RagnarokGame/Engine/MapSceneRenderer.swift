//
//  MapSceneRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokRendering
import RagnarokShaders
import simd

/// Draws the map.
///
/// The renderer owns the Metal objects and nothing else. What to draw arrives in a
/// `MapSceneRenderer.Scene`, which `MapScene` builds once per frame, so every
/// view of a frame draws the same contents from its own camera.
final class MapSceneRenderer {
    struct Scene {
        struct Effect {
            let resourceGroup: EffectRenderResourceGroup
            let attachedWorldPosition: SIMD3<Float>?
        }

        struct Gauge {
            let vertices: [SpriteVertex]
            let worldPosition: SIMD3<Float>
        }

        struct TileSelector {
            let position: SIMD2<Int>
            let cell: MapGrid.Cell
            let texture: any MTLTexture
        }

        struct CombatText {
            let vertices: [SpriteVertex]
            let worldPosition: SIMD3<Float>
            let texture: any MTLTexture
        }

        var fog: Fog
        var world: WorldRenderResource?
        var tileSelector: MapSceneRenderer.Scene.TileSelector?
        var spriteDrawables: [SpriteLayerDrawable] = []
        var effects: [MapSceneRenderer.Scene.Effect] = []
        var gauges: [MapSceneRenderer.Scene.Gauge] = []
        var combatTexts: [MapSceneRenderer.Scene.CombatText] = []
    }

    /// The map's own transform. The game world stands the other way up from render space,
    /// so the whole map turns over.
    private static let worldModelMatrix = matrix_rotate(matrix_identity_float4x4, radians(-180), [1, 0, 0])

    let device: any MTLDevice
    let configuration: RenderConfiguration

    private let worldRenderer: WorldRenderer
    private let spriteRenderer: SpriteRenderer
    private let combatTextRenderer: CombatTextRenderer
    private let gaugeRenderer: GaugeRenderer
    private let effectRenderer: EffectRenderer
    private let tileSelectorRenderer: TileSelectorRenderer

    init(configuration: RenderConfiguration) throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("MapRuntimeRenderer: Metal is not available on this device")
        }
        self.device = device
        self.configuration = configuration

        worldRenderer = try WorldRenderer(device: device, configuration: configuration)
        spriteRenderer = try SpriteRenderer(device: device, configuration: configuration)
        combatTextRenderer = try CombatTextRenderer(device: device, configuration: configuration)
        gaugeRenderer = try GaugeRenderer(device: device, configuration: configuration)
        effectRenderer = try EffectRenderer(device: device, configuration: configuration)
        tileSelectorRenderer = try TileSelectorRenderer(device: device, configuration: configuration)
    }

    /// Where a game world position sits in the space the map is drawn in.
    static func renderPosition(for worldPosition: SIMD3<Float>) -> SIMD3<Float> {
        [
            worldPosition.x,
            worldPosition.z,
            -worldPosition.y,
        ]
    }

    func render(frame: RenderFrame, scene: MapSceneRenderer.Scene) {
        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        renderPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            renderScene(
                scene,
                atTime: frame.time,
                viewport: view.viewport,
                camera: view.camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderCommandEncoder.endEncoding()
    }

    private func renderScene(
        _ scene: MapSceneRenderer.Scene,
        atTime time: TimeInterval,
        viewport: MTLViewport,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        let modelMatrix = Self.worldModelMatrix

        if let world = scene.world {
            worldRenderer.renderGroundAndModels(
                resource: world,
                atTime: time,
                fog: scene.fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )

            worldRenderer.renderEffects(
                resource: world,
                atTime: time,
                beforeEntities: true,
                fog: scene.fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderEffects(
            scene.effects,
            beforeEntities: true,
            atTime: time,
            fog: scene.fog,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        spriteRenderer.render(
            drawables: scene.spriteDrawables,
            viewport: viewport,
            fog: scene.fog,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        // Water renders after sprites so submerged
        // sprites blend through the translucent surface.
        if let world = scene.world {
            worldRenderer.renderWater(
                resource: world,
                atTime: time,
                fog: scene.fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )

            worldRenderer.renderEffects(
                resource: world,
                atTime: time,
                beforeEntities: false,
                fog: scene.fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderEffects(
            scene.effects,
            beforeEntities: false,
            atTime: time,
            fog: scene.fog,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        if let tileSelector = scene.tileSelector {
            tileSelectorRenderer.render(
                tileSelector: tileSelector,
                fog: scene.fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        gaugeRenderer.render(
            gauges: scene.gauges,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        // Combat text renders last so nothing draws over it.
        combatTextRenderer.render(
            combatTexts: scene.combatTexts,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    private func renderEffects(
        _ effects: [MapSceneRenderer.Scene.Effect],
        beforeEntities: Bool,
        atTime time: TimeInterval,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        for effect in effects where effect.resourceGroup.rendersBeforeEntities == beforeEntities {
            effectRenderer.render(
                resourceGroup: effect.resourceGroup,
                atTime: time,
                attachedWorldPosition: effect.attachedWorldPosition,
                fog: fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }
    }
}
