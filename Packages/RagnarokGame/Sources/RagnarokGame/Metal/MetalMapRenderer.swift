//
//  MetalMapRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import CoreGraphics
import Foundation
import Metal
import RagnarokCore
import RagnarokRenderers
import simd

final class MetalMapRenderer: Renderer {
    private static let cameraTargetOffset = SIMD3<Float>(0, 0.5, 0)
    private static let fieldOfViewDegrees: Float = 15

    struct RenderMatrices {
        var modelMatrix: simd_float4x4
        var viewMatrix: simd_float4x4
        var projectionMatrix: simd_float4x4
        var normalMatrix: simd_float3x3
        var cameraPosition: SIMD3<Float>
        var cameraAzimuth: Float
    }

    let device: any MTLDevice

    private let skyboxRenderer: SkyboxRenderer
    private let worldRenderer: WorldRenderer
    private let spriteRenderer: MetalSpriteRenderer
    private let combatTextRenderer: MetalCombatTextRenderer
    private let effectRenderer: EffectRenderer
    private let tileSelectorRenderer: MetalTileSelectorRenderer

    var skyboxResource: SkyboxRenderResource?
    var worldResource: WorldRenderResource?
    var spriteDrawables: [SpriteLayerDrawable] = []
    var combatTextRenderResources: [CombatTextRenderResource] = []
    var objects: [GameObjectID : MetalMapObject] = [:]
    var effects: [MetalMapEffect] = []
    var tileSelectorResource: TileSelectorRenderResource?

    private var cameraState = MapCameraState()
    private var targetPosition: SIMD3<Float> = .zero

    private(set) var lastRenderMatrices: RenderMatrices?
    private(set) var lastViewport: CGRect = .zero

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("MapRuntimeRenderer: Metal is not available on this device")
        }
        self.device = device

        skyboxRenderer = try SkyboxRenderer(device: device)
        worldRenderer = try WorldRenderer(device: device)
        spriteRenderer = try MetalSpriteRenderer(device: device)
        combatTextRenderer = try MetalCombatTextRenderer(device: device)
        effectRenderer = try EffectRenderer(device: device)
        tileSelectorRenderer = try MetalTileSelectorRenderer(device: device)
    }

    func renderPosition(for worldPosition: SIMD3<Float>) -> SIMD3<Float> {
        [
            worldPosition.x,
            worldPosition.z,
            -worldPosition.y,
        ]
    }

    func updateCamera(cameraState: MapCameraState, targetPosition: SIMD3<Float>) {
        self.cameraState = cameraState
        self.targetPosition = targetPosition
    }

    func render(
        atTime time: TimeInterval,
        viewport: CGRect,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        if let depthAttachment = renderPassDescriptor.depthAttachment {
            depthAttachment.loadAction = .clear
            depthAttachment.storeAction = .dontCare
            depthAttachment.clearDepth = 1
        }

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        let matrices = makeRenderMatrices(viewport: viewport)
        lastRenderMatrices = matrices
        lastViewport = viewport

        if let skyboxResource {
            skyboxRenderer.render(
                resource: skyboxResource,
                renderCommandEncoder: renderCommandEncoder,
                projectionMatrix: matrices.projectionMatrix,
                viewMatrix: matrices.viewMatrix,
                cameraPosition: matrices.cameraPosition
            )
        }

        if let worldResource {
            worldRenderer.renderGroundAndModels(
                resource: worldResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                normalMatrix: matrices.normalMatrix
            )
        }

        if let worldResource {
            worldRenderer.renderEffects(
                resource: worldResource,
                atTime: time,
                beforeEntities: true,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                cameraAzimuth: matrices.cameraAzimuth
            )
        }

        renderEffects(
            effects.filter { $0.renderResourceGroup?.rendersBeforeEntities == true },
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )

        let framebufferSize = SIMD2<Float>(
            Float(renderPassDescriptor.colorAttachments[0].texture?.width ?? 0),
            Float(renderPassDescriptor.colorAttachments[0].texture?.height ?? 0)
        )
        spriteRenderer.render(
            drawables: spriteDrawables,
            framebufferSize: framebufferSize,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )

        // Water renders after sprites so submerged
        // sprites blend through the translucent surface.
        if let worldResource {
            worldRenderer.renderWater(
                resource: worldResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix
            )
        }

        if let worldResource {
            worldRenderer.renderEffects(
                resource: worldResource,
                atTime: time,
                beforeEntities: false,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                cameraAzimuth: matrices.cameraAzimuth
            )
        }

        renderEffects(
            effects.filter { $0.renderResourceGroup?.rendersBeforeEntities == false },
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )

        if let tileSelectorResource {
            tileSelectorRenderer.render(
                resource: tileSelectorResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                matrices: matrices
            )
        }

        // Combat text renders last so nothing draws over it.
        combatTextRenderer.render(
            resources: combatTextRenderResources,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )

        renderCommandEncoder.endEncoding()
    }

    private func renderEffects(
        _ effects: [MetalMapEffect],
        atTime time: TimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: RenderMatrices
    ) {
        let sortedEffects = effects.sorted {
            guard let lhsCreationTime = $0.renderResourceGroup?.creationTime else {
                return false
            }
            guard let rhsCreationTime = $1.renderResourceGroup?.creationTime else {
                return true
            }
            return lhsCreationTime < rhsCreationTime
        }

        for effect in sortedEffects {
            guard let resourceGroup = effect.renderResourceGroup else {
                continue
            }

            let targetObject = effect.targetObjectID.flatMap { objects[$0] }

            effectRenderer.render(
                resourceGroup: resourceGroup,
                atTime: time,
                attachedWorldPosition: targetObject?.worldPosition,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                cameraAzimuth: matrices.cameraAzimuth
            )
        }
    }

    private func makeRenderMatrices(viewport: CGRect) -> RenderMatrices {
        let modelMatrix = makeWorldModelMatrix()
        let worldTarget = renderPosition(for: targetPosition) + Self.cameraTargetOffset

        let cameraOrientation =
            simd_quatf(angle: -cameraState.azimuth, axis: [0, 1, 0]) *
            simd_quatf(angle: -cameraState.elevation, axis: [1, 0, 0])
        let cameraPosition = worldTarget + cameraOrientation.act([0, 0, cameraState.distance])
        let cameraUp = cameraOrientation.act([0, 1, 0])

        let viewportHeight = max(Float(viewport.height), 1)
        let aspectRatio = max(Float(viewport.width) / viewportHeight, .leastNonzeroMagnitude)
        let farZ = max(cameraState.distance * 4, 1000)

        return RenderMatrices(
            modelMatrix: modelMatrix,
            viewMatrix: lookAt(cameraPosition, worldTarget, cameraUp),
            projectionMatrix: perspective(radians(Self.fieldOfViewDegrees), aspectRatio, 0.1, farZ),
            normalMatrix: simd_float3x3(modelMatrix).inverse.transpose,
            cameraPosition: cameraPosition,
            cameraAzimuth: cameraState.azimuth
        )
    }

    private func makeWorldModelMatrix() -> simd_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])
        return modelMatrix
    }
}
