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
        case sprite(SpriteRenderer.RenderPayload)
        case effect(EffectRenderer.RenderPayload)
    }

    private let renderQueue = RenderQueue<RenderPayload>()
    private var waterDepthTexture: (any MTLTexture)?

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
        let activeWaterDepthTexture = renderWaterDepthIfNeeded(frame: frame, snapshot: snapshot)

        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        renderPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        collectSnapshot(snapshot, atTime: frame.time, includeWater: activeWaterDepthTexture == nil)

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            renderSnapshot(
                snapshot,
                atTime: frame.time,
                viewport: view.viewport,
                camera: view.camera,
                waterDepthTexture: activeWaterDepthTexture,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderCommandEncoder.endEncoding()
    }

    private func renderWaterDepthIfNeeded(frame: RenderFrame, snapshot: MapSceneRenderSnapshot) -> (any MTLTexture)? {
        guard let world = snapshot.world, world.hasWater,
              let targetDepthTexture = frame.renderPassDescriptor.depthAttachment.texture,
              let depthTexture = ensureWaterDepthTexture(matching: targetDepthTexture) else {
            return nil
        }

        let waterDepthPassDescriptor = MTLRenderPassDescriptor()
        waterDepthPassDescriptor.depthAttachment.texture = depthTexture
        waterDepthPassDescriptor.depthAttachment.loadAction = .clear
        waterDepthPassDescriptor.depthAttachment.storeAction = .store
        waterDepthPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth
        waterDepthPassDescriptor.rasterizationRateMap = frame.renderPassDescriptor.rasterizationRateMap

        guard let waterDepthEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: waterDepthPassDescriptor) else {
            return nil
        }

        for view in frame.views {
            waterDepthEncoder.setViewport(view.viewport)
            worldRenderer.renderWaterDepth(
                resource: world,
                atTime: frame.time,
                modelMatrix: matrix_identity_float4x4,
                camera: view.camera,
                renderCommandEncoder: waterDepthEncoder
            )
        }

        waterDepthEncoder.endEncoding()
        return depthTexture
    }

    private func ensureWaterDepthTexture(matching depthTexture: any MTLTexture) -> (any MTLTexture)? {
        if let waterDepthTexture,
           waterDepthTexture.width == depthTexture.width,
           waterDepthTexture.height == depthTexture.height,
           waterDepthTexture.pixelFormat == configuration.depthStencilPixelFormat {
            return waterDepthTexture
        }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: configuration.depthStencilPixelFormat,
            width: depthTexture.width,
            height: depthTexture.height,
            mipmapped: false
        )
        descriptor.usage = [.renderTarget, .shaderRead]
        descriptor.storageMode = .private

        waterDepthTexture = device.makeTexture(descriptor: descriptor)
        return waterDepthTexture
    }

    private func collectSnapshot(_ snapshot: MapSceneRenderSnapshot, atTime time: TimeInterval,includeWater: Bool) {
        renderQueue.removeAll()

        if let world = snapshot.world {
            worldRenderer.submit(
                resource: world,
                atTime: time,
                fog: snapshot.fog,
                modelMatrix: matrix_identity_float4x4,
                includeWater: includeWater,
                into: renderQueue,
                transform: RenderPayload.world
            )
        }

        spriteRenderer.submit(
            drawables: snapshot.spriteDrawables,
            fog: snapshot.fog,
            modelMatrix: matrix_identity_float4x4,
            into: renderQueue,
            transform: RenderPayload.sprite
        )

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
        waterDepthTexture: (any MTLTexture)?,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        renderQueue.sort(camera: camera)

        flush(
            bucket: .opaque,
            viewport: viewport,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        flush(
            bucket: .groundDecal,
            viewport: viewport,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        if let waterDepthTexture, let world = snapshot.world {
            // Stage 1: fragments strictly behind the water surface
            flush(
                bucket: .translucent,
                viewport: viewport,
                camera: camera,
                waterClipMode: 1,
                waterDepthTexture: waterDepthTexture,
                includeEffects: false,
                renderCommandEncoder: renderCommandEncoder
            )

            // Stage 2: water surface
            worldRenderer.renderWater(
                resource: world,
                atTime: time,
                fog: snapshot.fog,
                modelMatrix: matrix_identity_float4x4,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )

            // Stage 3: fragments in front of (or outside) the water surface, plus effects
            flush(
                bucket: .translucent,
                viewport: viewport,
                camera: camera,
                waterClipMode: 2,
                waterDepthTexture: waterDepthTexture,
                includeEffects: true,
                renderCommandEncoder: renderCommandEncoder
            )
        } else {
            flush(
                bucket: .translucent,
                viewport: viewport,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        flush(
            bucket: .overlay,
            viewport: viewport,
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
        viewport: MTLViewport,
        camera: RenderCamera,
        waterClipMode: Int32 = 0,
        waterDepthTexture: (any MTLTexture)? = nil,
        includeEffects: Bool = true,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        for item in renderQueue.items(in: bucket) {
            switch item.payload {
            case .world(let payload):
                if case .effect = payload, !includeEffects {
                    continue
                }
                worldRenderer.render(
                    payload: payload,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .sprite(let payload):
                spriteRenderer.render(
                    payload: payload,
                    viewport: viewport,
                    camera: camera,
                    waterClipMode: waterClipMode,
                    waterDepthTexture: waterDepthTexture,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .effect(let payload):
                guard includeEffects else {
                    continue
                }
                effectRenderer.render(
                    payload: payload,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            }
        }
    }
}
