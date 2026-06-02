//
//  RSWFilePreviewRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//

import Metal
import RagnarokCore
import RagnarokMetalRendering
import RagnarokRenderAssets
import simd

public class RSWFilePreviewRenderer: Renderer {
    public let device: any MTLDevice

    let groundAsset: GroundRenderAsset
    let groundResource: GroundRenderResource
    let groundRenderer: GroundRenderer

    let waterResource: WaterRenderResource
    let waterRenderer: WaterRenderer
    let modelResources: [RSMModelRenderResource]
    let modelRenderer: RSMModelRenderer

    public let camera: OrbitalCamera

    private var lastModelMatrix = matrix_identity_float4x4
    private var lastViewMatrix = matrix_identity_float4x4
    private var lastProjectionMatrix = matrix_identity_float4x4
    private var lastViewport: CGRect = .zero

    public init(device: any MTLDevice, worldAsset: WorldAsset) throws {
        self.device = device
        self.groundAsset = worldAsset.ground

        groundResource = GroundRenderResource(device: device, asset: groundAsset)
        waterResource = WaterRenderResource(device: device, asset: worldAsset.water)
        modelResources = worldAsset.modelGroups.map { modelGroup in
            RSMModelRenderResource(
                device: device,
                prototype: modelGroup.prototype,
                instances: modelGroup.instances
            )
        }

        groundRenderer = try GroundRenderer(device: device)
        waterRenderer = try WaterRenderer(device: device)
        modelRenderer = try RSMModelRenderer(device: device)

        let defaultDistance = -groundAsset.altitude / 5 + 200
        camera = OrbitalCamera(distance: defaultDistance)
        camera.elevation = .pi / 2
        camera.minimumDistance = defaultDistance - 190
        camera.maximumDistance = defaultDistance + 200
        camera.farZ = 500
    }

    public func focusTile(at screenPoint: CGPoint) {
        guard let tileCenter = tileCenter(at: screenPoint) else {
            return
        }
        camera.animatePan(to: SIMD3<Float>(tileCenter.x, 0, tileCenter.z))
    }

    public func render(
        atTime time: CFTimeInterval,
        viewport: CGRect,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1

        camera.update(atTime: time)
        camera.update(size: viewport.size)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])
        modelMatrix = matrix_translate(modelMatrix, [-Float(groundAsset.width / 2), 0, -Float(groundAsset.height / 2)])

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix
        let normalMatrix = simd_float3x3(modelMatrix).inverse.transpose

        lastModelMatrix = modelMatrix
        lastViewMatrix = viewMatrix
        lastProjectionMatrix = projectionMatrix
        lastViewport = viewport

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        groundRenderer.render(
            resource: groundResource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        waterRenderer.render(
            resource: waterResource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix
        )

        modelRenderer.render(
            resources: modelResources,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        renderCommandEncoder.endEncoding()
    }
}

extension RSWFilePreviewRenderer {
    private func tileCenter(at screenPoint: CGPoint) -> SIMD3<Float>? {
        guard let (origin, direction) = ray(through: screenPoint) else {
            return nil
        }

        let inverseModelMatrix = lastModelMatrix.inverse
        let localOrigin4 = inverseModelMatrix * SIMD4<Float>(origin.x, origin.y, origin.z, 1)
        let localDirection4 = inverseModelMatrix * SIMD4<Float>(direction.x, direction.y, direction.z, 0)

        let localOrigin = SIMD3<Float>(localOrigin4.x, localOrigin4.y, localOrigin4.z) / localOrigin4.w
        let localDirection = simd_normalize(SIMD3<Float>(localDirection4.x, localDirection4.y, localDirection4.z))

        guard abs(localDirection.y) > .leastNonzeroMagnitude else {
            return nil
        }

        let distance = -localOrigin.y / localDirection.y
        guard distance >= 0 else {
            return nil
        }

        let localHit = localOrigin + localDirection * distance
        let tileX = Int(floor(localHit.x / 2))
        let tileY = Int(floor(localHit.z / 2))

        guard (0..<groundAsset.width).contains(tileX), (0..<groundAsset.height).contains(tileY) else {
            return nil
        }

        let localCenter = SIMD4<Float>(
            (Float(tileX) + 0.5) * 2,
            0,
            (Float(tileY) + 0.5) * 2,
            1
        )
        let center = lastModelMatrix * localCenter
        return SIMD3<Float>(center.x, center.y, center.z) / center.w
    }

    private func ray(through screenPoint: CGPoint) -> (origin: SIMD3<Float>, direction: SIMD3<Float>)? {
        guard lastViewport.width > 0, lastViewport.height > 0 else {
            return nil
        }

        let pvInverse = (lastProjectionMatrix * lastViewMatrix).inverse
        if pvInverse[0][0].isNaN {
            return nil
        }

        let ndcX = Float((screenPoint.x - lastViewport.minX) / lastViewport.width) * 2 - 1
        let ndcY = 1 - Float((screenPoint.y - lastViewport.minY) / lastViewport.height) * 2

        let nearWorld = pvInverse * SIMD4<Float>(ndcX, ndcY, 0, 1)
        let farWorld = pvInverse * SIMD4<Float>(ndcX, ndcY, 1, 1)

        let nearPosition = SIMD3<Float>(nearWorld.x, nearWorld.y, nearWorld.z) / nearWorld.w
        let farPosition = SIMD3<Float>(farWorld.x, farWorld.y, farWorld.z) / farWorld.w

        return (nearPosition, simd_normalize(farPosition - nearPosition))
    }
}
