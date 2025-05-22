//
//  RSMRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//

import Metal
import ROCore
import ROShaders

public class RSMRenderer: Renderer {
    public let device: any MTLDevice

    let modelRenderer: ModelRenderer

    public let camera = Camera()

    public init(device: any MTLDevice, model: Model, textures: [String : any MTLTexture]) throws {
        self.device = device

        let library = ROCreateShadersLibrary(device)!
        modelRenderer = try ModelRenderer(device: device, library: library, models: [model], textures: textures)
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

        let model = modelRenderer.models[0]
        let scale = 2 / model.boundingBox.range.max()

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
