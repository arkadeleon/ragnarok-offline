//
//  STRRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/24.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit

class STRRenderer: NSObject, Renderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let effectRenderer: EffectRenderer

    let camera = Camera()

    init(device: MTLDevice, effect: Effect) throws {
        self.device = device

        commandQueue = device.makeCommandQueue()!

        let library = device.makeDefaultLibrary()!
        effectRenderer = try EffectRenderer(device: device, library: library, effect: effect)

        super.init()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {
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

        camera.update(size: view.bounds.size)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_translate(modelMatrix, [-10, 10, 20])
        modelMatrix = matrix_rotate(modelMatrix, radians(270), [1, 0, 0])

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        effectRenderer.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix
        )

        renderCommandEncoder.endEncoding()

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
