//
//  MapSceneRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokEffects
import RagnarokRendering
import RagnarokShaders
import simd

/// Draws the map.
///
/// The renderer owns the Metal objects and nothing else. What to draw arrives in a
/// `MapSceneRenderSnapshot`, which is built once per frame so every view of a frame
/// draws the same contents from its own camera.
final class MapSceneRenderer {
    private enum RenderPayload {
        case world(WorldRenderer.RenderPayload)
        case sprite(SpriteRenderer.RenderPayload)
        case effect(EffectRenderer.RenderPayload)
        case strEffect(STREffectRenderer.RenderPayload)
        case primitiveEffect(EffectPrimitiveBatchRenderer.RenderPayload)
        case tileSelector(MapSceneRenderSnapshot.TileSelector, fog: Fog, modelMatrix: simd_float4x4)
        case targetSelector(MapSceneRenderSnapshot.TargetSelector, modelMatrix: simd_float4x4)
        case bars([MapSceneRenderSnapshot.Bar], modelMatrix: simd_float4x4)
        case texts([MapSceneRenderSnapshot.Text], modelMatrix: simd_float4x4)
        case combatTexts([MapSceneRenderSnapshot.CombatText], texture: (any MTLTexture)?, modelMatrix: simd_float4x4)
    }

    let device: any MTLDevice
    let configuration: RenderConfiguration

    private let renderQueue = RenderQueue<RenderPayload>()
    private let worldRenderer: WorldRenderer
    private let spriteRenderer: SpriteRenderer
    private let textRenderer: TextRenderer
    private let combatTextRenderer: CombatTextRenderer
    private let barRenderer: BarRenderer
    private let effectRenderer: EffectRenderer
    private let strEffectRenderer: STREffectRenderer
    private let primitiveBatchRenderer: EffectPrimitiveBatchRenderer
    private let tileSelectorRenderer: TileSelectorRenderer
    private let targetSelectorRenderer: TargetSelectorRenderer

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
        strEffectRenderer = try STREffectRenderer(device: device, configuration: configuration)
        primitiveBatchRenderer = try EffectPrimitiveBatchRenderer(device: device, configuration: configuration)
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
        let rasterizationRateMap = frame.renderPassDescriptor.rasterizationRateMap
        guard let world = snapshot.world, world.hasWater,
              let targetDepthTexture = frame.renderPassDescriptor.depthAttachment.texture,
              let depthTexture = ensureWaterDepthTexture(matching: targetDepthTexture, rasterizationRateMap: rasterizationRateMap) else {
            return nil
        }

        // Rasterize water depth in logical screen space (without foveation) so
        // `waterDepthTexture.read(uint2(in.position.xy))` aligns 1:1 with fragment coordinates.
        let waterDepthPassDescriptor = MTLRenderPassDescriptor()
        waterDepthPassDescriptor.depthAttachment.texture = depthTexture
        waterDepthPassDescriptor.depthAttachment.loadAction = .clear
        waterDepthPassDescriptor.depthAttachment.storeAction = .store
        waterDepthPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth

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

    private func ensureWaterDepthTexture(
        matching depthTexture: any MTLTexture,
        rasterizationRateMap: (any MTLRasterizationRateMap)?
    ) -> (any MTLTexture)? {
        let width = rasterizationRateMap?.screenSize.width ?? depthTexture.width
        let height = rasterizationRateMap?.screenSize.height ?? depthTexture.height

        if let waterDepthTexture,
           waterDepthTexture.width == width,
           waterDepthTexture.height == height,
           waterDepthTexture.pixelFormat == configuration.depthStencilPixelFormat {
            return waterDepthTexture
        }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: configuration.depthStencilPixelFormat,
            width: width,
            height: height,
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

        for payload in snapshot.strEffectPayloads {
            strEffectRenderer.submit(
                payload: payload,
                into: renderQueue,
                transformPayload: RenderPayload.strEffect
            )
        }

        for payload in snapshot.primitiveEffectPayloads {
            primitiveBatchRenderer.submit(
                payload: payload,
                into: renderQueue,
                transformPayload: RenderPayload.primitiveEffect
            )
        }

        if let tileSelector = snapshot.tileSelector {
            renderQueue.submit(
                bucket: .overlay,
                payload: .tileSelector(tileSelector, fog: snapshot.fog, modelMatrix: matrix_identity_float4x4)
            )
        }

        if let targetSelector = snapshot.targetSelector {
            renderQueue.submit(
                bucket: .overlay,
                payload: .targetSelector(targetSelector, modelMatrix: matrix_identity_float4x4)
            )
        }

        if !snapshot.bars.isEmpty {
            renderQueue.submit(
                bucket: .overlay,
                payload: .bars(snapshot.bars, modelMatrix: matrix_identity_float4x4)
            )
        }

        if !snapshot.texts.isEmpty {
            renderQueue.submit(
                bucket: .overlay,
                payload: .texts(snapshot.texts, modelMatrix: matrix_identity_float4x4)
            )
        }

        // Combat text submits last so nothing draws over it.
        if !snapshot.combatTexts.isEmpty {
            renderQueue.submit(
                bucket: .overlay,
                payload: .combatTexts(
                    snapshot.combatTexts,
                    texture: snapshot.combatTextTexture,
                    modelMatrix: matrix_identity_float4x4
                )
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
                translucentPass: .behindWater,
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
                translucentPass: .inFrontOfWater,
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
    }

    private func flush(
        bucket: RenderPassBucket,
        viewport: MTLViewport,
        camera: RenderCamera,
        waterClipMode: Int32 = 0,
        waterDepthTexture: (any MTLTexture)? = nil,
        translucentPass: RenderTranslucentPasses? = nil,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        for item in renderQueue.items(in: bucket) {
            if let translucentPass, !item.translucentPasses.contains(translucentPass) {
                continue
            }

            switch item.payload {
            case .world(let payload):
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
                effectRenderer.render(
                    payload: payload,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .strEffect(let payload):
                strEffectRenderer.render(
                    payload: payload,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .primitiveEffect(let payload):
                primitiveBatchRenderer.render(
                    payload: payload,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .tileSelector(let tileSelector, let fog, let modelMatrix):
                tileSelectorRenderer.render(
                    tileSelector: tileSelector,
                    fog: fog,
                    modelMatrix: modelMatrix,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .targetSelector(let targetSelector, let modelMatrix):
                targetSelectorRenderer.render(
                    targetSelector: targetSelector,
                    modelMatrix: modelMatrix,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .bars(let bars, let modelMatrix):
                barRenderer.render(
                    bars: bars,
                    modelMatrix: modelMatrix,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .texts(let texts, let modelMatrix):
                textRenderer.render(
                    texts: texts,
                    modelMatrix: modelMatrix,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .combatTexts(let combatTexts, let texture, let modelMatrix):
                combatTextRenderer.render(
                    combatTexts: combatTexts,
                    texture: texture,
                    modelMatrix: modelMatrix,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            }
        }
    }
}
