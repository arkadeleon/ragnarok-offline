//
//  RSWRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit

class RSWRenderer: NSObject, Renderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let groundRenderer: GroundRenderer
    let waterRenderer: WaterRenderer
    let modelRenderer: ModelRenderer

    let camera = Camera()

    init(device: MTLDevice, ground: Ground, water: Water, models: [Model]) throws {
        self.device = device

        commandQueue = device.makeCommandQueue()!

        let library = device.makeDefaultLibrary()!
        groundRenderer = try GroundRenderer(device: device, library: library, ground: ground)
        waterRenderer = try WaterRenderer(device: device, library: library, water: water)
        modelRenderer = try ModelRenderer(device: device, library: library, models: models)

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

        let ground = groundRenderer.ground

        camera.update(size: view.bounds.size)

        let scale = 1 / Float(max(ground.width, ground.height) / 2)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_scale(modelMatrix, [-scale, scale, scale])
        modelMatrix = matrix_rotate(modelMatrix, radians(180), [0, 0, 1])
        modelMatrix = matrix_rotate(modelMatrix, radians(90), [1, 0, 0])
        modelMatrix = matrix_translate(modelMatrix, [-Float(ground.width / 2), ground.maxAltitude / 5, -Float(ground.height / 2)])

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix

        let normalMatrix = simd_float3x3(modelMatrix).inverse.transpose

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        groundRenderer.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        waterRenderer.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix
        )

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
