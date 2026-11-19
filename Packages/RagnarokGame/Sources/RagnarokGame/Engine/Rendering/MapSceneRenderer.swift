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
/// `MapSceneRenderSnapshot`, which is built once per frame so every view of a frame
/// draws the same contents from its own camera.
final class MapSceneRenderer {
    let device: any MTLDevice
    let configuration: RenderConfiguration

    private let worldRenderer: WorldRenderer
    private let spriteRenderer: SpriteRenderer
    private let textRenderer: TextRenderer
    private let combatTextRenderer: CombatTextRenderer
    private let barRenderer: BarRenderer
    private let effectRenderer: EffectRenderer
    private let tileSelectorRenderer: TileSelectorRenderer
    private let targetSelectorRenderer: TargetSelectorRenderer

    private enum RenderPayload {
        case world(WorldRenderer.RenderPayload)
        case effect(EffectRenderer.RenderPayload)
    }

    private let renderQueue = RenderQueue<RenderPayload>()

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device
        self.configuration = configuration

        worldRenderer = try WorldRenderer(device: device, configuration: configuration)
        spriteRenderer = try SpriteRenderer(device: device, configuration: configuration)
        textRenderer = try TextRenderer(device: device, configuration: configuration)
        combatTextRenderer = try CombatTextRenderer(device: device, configuration: configuration)
        barRenderer = try BarRenderer(device: device, configuration: configuration)
        effectRenderer = try EffectRenderer(device: device, configuration: configuration)
        tileSelectorRenderer = try TileSelectorRenderer(device: device, configuration: configuration)
        targetSelectorRenderer = try TargetSelectorRenderer(device: device, configuration: configuration)
    }

    func render(frame: RenderFrame, snapshot: MapSceneRenderSnapshot) {
        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        renderPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        collectSnapshot(snapshot, atTime: frame.time)

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            renderSnapshot(
                snapshot,
                atTime: frame.time,
                viewport: view.viewport,
                camera: view.camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderCommandEncoder.endEncoding()
    }

    private func collectSnapshot(_ snapshot: MapSceneRenderSnapshot, atTime time: TimeInterval) {
        renderQueue.removeAll()

        if let world = snapshot.world {
            worldRenderer.submit(
                resource: world,
                atTime: time,
                fog: snapshot.fog,
                modelMatrix: matrix_identity_float4x4,
                includeWater: false,
                into: renderQueue,
                transform: RenderPayload.world
            )
        }

        for effect in snapshot.effects {
            effectRenderer.submit(
                resourceGroup: effect.resourceGroup,
                atTime: time,
                attachedWorldPosition: effect.attachedWorldPosition,
                fog: snapshot.fog,
                modelMatrix: matrix_identity_float4x4,
                into: renderQueue,
                transform: RenderPayload.effect
            )
        }
    }

    private func renderSnapshot(
        _ snapshot: MapSceneRenderSnapshot,
        atTime time: TimeInterval,
        viewport: MTLViewport,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        renderQueue.sort(camera: camera)

        flush(
            bucket: .opaque,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        flush(
            bucket: .groundDecal,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        spriteRenderer.render(
            drawables: snapshot.spriteDrawables,
            viewport: viewport,
            fog: snapshot.fog,
            modelMatrix: matrix_identity_float4x4,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        if let world = snapshot.world {
            worldRenderer.renderWater(
                resource: world,
                atTime: time,
                fog: snapshot.fog,
                modelMatrix: matrix_identity_float4x4,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        flush(
            bucket: .translucent,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        flush(
            bucket: .overlay,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        if let tileSelector = snapshot.tileSelector {
            tileSelectorRenderer.render(
                tileSelector: tileSelector,
                fog: snapshot.fog,
                modelMatrix: matrix_identity_float4x4,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        if let targetSelector = snapshot.targetSelector {
            targetSelectorRenderer.render(
                targetSelector: targetSelector,
                modelMatrix: matrix_identity_float4x4,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        barRenderer.render(
            bars: snapshot.bars,
            modelMatrix: matrix_identity_float4x4,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        textRenderer.render(
            texts: snapshot.texts,
            modelMatrix: matrix_identity_float4x4,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        // Combat text renders last so nothing draws over it.
        combatTextRenderer.render(
            combatTexts: snapshot.combatTexts,
            texture: snapshot.combatTextTexture,
            modelMatrix: matrix_identity_float4x4,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    private func flush(
        bucket: RenderPassBucket,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        for item in renderQueue.items(in: bucket) {
            switch item.payload {
            case .world(let payload):
                worldRenderer.render(
                    payload: payload,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .effect(let payload):
                effectRenderer.render(
                    payload: payload,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            }
        }
    }
}
