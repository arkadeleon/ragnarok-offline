//
//  MetalMapRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import CoreGraphics
import Metal
import RagnarokCore
import RagnarokMetalRendering
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
    }

    let device: any MTLDevice

    private let skyboxRenderer: SkyboxRenderer
    private let groundRenderer: GroundRenderer
    private let waterRenderer: WaterRenderer
    private let modelRenderer: RSMModelRenderer
    private let spriteRenderer: MetalSpriteRenderer
    private let tileSelectorRenderer: MetalTileSelectorRenderer

    var skyboxResource: SkyboxRenderResource?
    var groundResource: GroundRenderResource?
    var waterResource: WaterRenderResource?
    var modelResources: [RSMModelRenderResource] = []
    var spriteDrawables: [SpriteLayerDrawable] = []
    var damageEffectResources: [UUID : DamageEffectRenderResource] = [:]
    var tileSelectorResource: TileSelectorRenderResource?

    private var cameraState: MapCameraState = .default
    private var targetPosition: SIMD3<Float> = .zero

    private(set) var lastRenderMatrices: RenderMatrices?
    private(set) var lastViewport: CGRect = .zero

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("MapRuntimeRenderer: Metal is not available on this device")
        }
        self.device = device

        skyboxRenderer = try SkyboxRenderer(device: device)
        groundRenderer = try GroundRenderer(device: device)
        waterRenderer = try WaterRenderer(device: device)
        modelRenderer = try RSMModelRenderer(device: device)
        spriteRenderer = try MetalSpriteRenderer(device: device)
        tileSelectorRenderer = try MetalTileSelectorRenderer(device: device)
    }

    func updateCamera(cameraState: MapCameraState, targetPosition: SIMD3<Float>) {
        self.cameraState = cameraState
        self.targetPosition = targetPosition
    }

    func render(
        atTime time: CFTimeInterval,
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

        if let groundResource {
            groundRenderer.render(
                resource: groundResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                normalMatrix: matrices.normalMatrix
            )
        }

        if let waterResource {
            waterRenderer.render(
                resource: waterResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix
            )
        }

        modelRenderer.render(
            resources: modelResources,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: matrices.modelMatrix,
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix,
            normalMatrix: matrices.normalMatrix
        )

        let sortedDamageEffects = damageEffectResources.values.sorted { $0.creationTime < $1.creationTime }
        spriteRenderer.render(
            drawables: spriteDrawables,
            damageEffects: sortedDamageEffects,
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

        renderCommandEncoder.endEncoding()
    }

    private func makeRenderMatrices(viewport: CGRect) -> RenderMatrices {
        let modelMatrix = makeWorldModelMatrix()
        let worldTarget = targetPosition + Self.cameraTargetOffset

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
            cameraPosition: cameraPosition
        )
    }

    private func makeWorldModelMatrix() -> simd_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])
        return modelMatrix
    }
}
