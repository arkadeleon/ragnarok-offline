//
//  RSMRenderer.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2020/7/15.
//

import Metal
import RagnarokRenderAssets
import RagnarokShaders
import SGLMath

public class RSMRenderer: Renderer {
    public let device: any MTLDevice

    let modelBoundingBox: RSMModelBoundingBox
    let modelResource: RSMModelRenderResource
    let modelRenderer: RSMModelRenderer

    public let camera = Camera()

    public init(device: any MTLDevice, asset: RSMModelRenderAsset) throws {
        self.device = device
        modelBoundingBox = asset.model.boundingBox
        modelResource = RSMModelRenderResource(device: device, asset: asset)

        let library = RagnarokCreateShadersLibrary(device)!
        modelRenderer = try RSMModelRenderer(device: device, library: library)
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

        let scale = 2 / modelBoundingBox.range.max()

        camera.update(size: viewport.size)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_scale(modelMatrix, [scale, scale, scale])
        modelMatrix = matrix_rotate(modelMatrix, radians(-15), [1, 0, 0])
        modelMatrix = matrix_rotate(modelMatrix, Float(radians(time.truncatingRemainder(dividingBy: 8) * 360 / 8)), [0, 1, 0])

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix

        let normalMatrix = simd_float3x3(modelMatrix).inverse.transpose

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        modelRenderer.render(
            resource: modelResource,
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
