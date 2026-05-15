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

    public let camera: Camera

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

        camera = Camera()
        camera.defaultDistance = -groundAsset.altitude / 5 + 200
        camera.minimumDistance = camera.defaultDistance - 190
        camera.maximumDistance = camera.defaultDistance + 200
        camera.farZ = 500
    }

    public func render(
        atTime time: CFTimeInterval,
        viewport: CGRect,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        renderPassDescriptor.depthAttachment.clearDepth = 1

        camera.update(size: viewport.size)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_scale(modelMatrix, [1, -1, 1])
        modelMatrix = matrix_rotate(modelMatrix, radians(90), [1, 0, 0])
        modelMatrix = matrix_translate(modelMatrix, [-Float(groundAsset.width / 2), 0, -Float(groundAsset.height / 2)])

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix

        let normalMatrix = simd_float3x3(modelMatrix).inverse.transpose

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
