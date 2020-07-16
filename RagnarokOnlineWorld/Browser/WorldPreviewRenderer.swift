//
//  WorldPreviewRenderer.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/15.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit
import SGLMath

class WorldPreviewRenderer: NSObject {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let groundRenderer: GroundRenderer
    let waterRenderer: WaterRenderer
    let modelRenderer: ModelRenderer

    let camera = Camera()

    init(vertices: [GroundVertex], texture: Data?, waterVertices: [WaterVertex], waterTextures: [Data?], modelMeshes: [[ModelVertex]], modelTextures: [Data?]) throws {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!

        let library = device.makeDefaultLibrary()!
        groundRenderer = try GroundRenderer(device: device, library: library, vertices: vertices, texture: texture)
        waterRenderer = try WaterRenderer(device: device, library: library, vertices: waterVertices, textures: waterTextures)
        modelRenderer = try ModelRenderer(device: device, library: library, meshes: modelMeshes, textures: modelTextures)

        super.init()
    }
}

extension WorldPreviewRenderer: MTKViewDelegate {

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }

        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        renderPassDescriptor.depthAttachment.clearDepth = 1

        let time = CACurrentMediaTime()

        var modelviewMatrix = Matrix4x4<Float>()
        modelviewMatrix = SGLMath.translateZ(modelviewMatrix, -400)
        modelviewMatrix = SGLMath.rotate(modelviewMatrix, radians(15), [1, 0, 0])
        modelviewMatrix = SGLMath.rotate(modelviewMatrix, Float(radians(435595.22182600008 * 360 / 8)), [0, 1, 0])
        modelviewMatrix = SGLMath.translate(modelviewMatrix, [100, -40, 60])

        let projectionMatrix = SGLMath.perspective(radians(camera.zoom), Float(view.bounds.width / view.bounds.height), 1, 1000)

        let normalMatrix = Matrix3x3(modelviewMatrix).inverse.transpose

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        groundRenderer.render(
            atTime: time,
            device: device,
            renderCommandEncoder: renderCommandEncoder,
            modelviewMatrix: modelviewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        waterRenderer.render(
            atTime: time,
            device: device,
            renderCommandEncoder: renderCommandEncoder,
            modelviewMatrix: modelviewMatrix,
            projectionMatrix: projectionMatrix
        )

        modelRenderer.render(
            atTime: time,
            device: device,
            renderCommandEncoder: renderCommandEncoder,
            modelviewMatrix: modelviewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        renderCommandEncoder.endEncoding()

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
