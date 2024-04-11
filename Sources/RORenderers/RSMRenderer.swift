//
//  RSMRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit
import ROShaders

public class RSMRenderer: NSObject, Renderer {
    public let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let modelRenderer: ModelRenderer

    public let camera = Camera()

    public init(device: MTLDevice, model: Model) throws {
        self.device = device

        commandQueue = device.makeCommandQueue()!

        let library = ROCreateShadersLibrary(device)!
        modelRenderer = try ModelRenderer(device: device, library: library, models: [model])

        super.init()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    public func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }

//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        renderPassDescriptor.depthAttachment.clearDepth = 1

        let time = CACurrentMediaTime()

        let model = modelRenderer.models[0]
        let scale = 2 / model.boundingBox.range.max()

        camera.update(size: view.bounds.size)

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

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
