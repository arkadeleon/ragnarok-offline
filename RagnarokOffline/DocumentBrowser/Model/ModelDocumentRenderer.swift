//
//  ModelDocumentRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit

class ModelDocumentRenderer: NSObject, Renderer {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let modelRenderer: ModelRenderer

    let boundingBox: RSMBoundingBox
    let camera = Camera()

    init(meshes: [[ModelVertex]], textures: [Data?], boundingBox: RSMBoundingBox) throws {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!

        let library = device.makeDefaultLibrary()!
        modelRenderer = try ModelRenderer(device: device, library: library, meshes: meshes, textures: textures)

        self.boundingBox = boundingBox

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

        var modelviewMatrix = matrix_identity_float4x4
        modelviewMatrix = matrix_translate(modelviewMatrix, [0, -boundingBox.range[1] * 0.1, -boundingBox.range[1] * 0.5 - 5])
        modelviewMatrix = matrix_rotate(modelviewMatrix, radians(15), [1, 0, 0])
        modelviewMatrix = matrix_rotate(modelviewMatrix, Float(radians(time * 360 / 8)), [0, 1, 0])

        let projectionMatrix = perspective(radians(camera.zoom), Float(view.bounds.width / view.bounds.height), 1, 1000)

        let normalMatrix = simd_float3x3(modelviewMatrix).inverse.transpose

        modelRenderer.render(
            atTime: time,
            device: device,
            renderPassDescriptor: renderPassDescriptor,
            commandBuffer: commandBuffer,
            modelviewMatrix: modelviewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
