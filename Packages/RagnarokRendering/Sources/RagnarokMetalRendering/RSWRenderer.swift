//
//  RSWRenderer.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2020/7/15.
//

import Metal
import RagnarokRenderAssets
import RagnarokShaders
import SGLMath

public class RSWRenderer: Renderer {
    public let device: any MTLDevice

    let groundAsset: GroundRenderAsset
    let groundResource: GroundRenderResource
    let groundRenderer: GroundRenderer

    let waterResource: WaterRenderResource
    let waterRenderer: WaterRenderer
    let modelResources: [RSMModelRenderResource]
    let modelRenderer: RSMModelRenderer

    public let camera: Camera

    public init(
        device: any MTLDevice,
        groundAsset: GroundRenderAsset,
        waterAsset: WaterRenderAsset,
        modelAssets: [RSMModelRenderAsset]
    ) throws {
        self.device = device
        self.groundAsset = groundAsset

        groundResource = GroundRenderResource(device: device, asset: groundAsset)
        waterResource = WaterRenderResource(device: device, asset: waterAsset)
        modelResources = modelAssets.map { asset in
            RSMModelRenderResource(device: device, asset: asset)
        }

        let library = RagnarokCreateShadersLibrary(device)!
        groundRenderer = try GroundRenderer(device: device, library: library)
        waterRenderer = try WaterRenderer(device: device, library: library)
        modelRenderer = try RSMModelRenderer(device: device, library: library)

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

        for modelResource in modelResources {
            modelRenderer.render(
                resource: modelResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: modelMatrix,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                normalMatrix: normalMatrix
            )
        }

        renderCommandEncoder.endEncoding()
    }
}
