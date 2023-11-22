//
//  RSMRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit

class RSMRenderer: NSObject, Renderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let modelRenderer: ModelRenderer

    let boundingBox: RSMBoundingBox

    var camera = Camera()

    init(device: MTLDevice, meshes: [ModelMesh], boundingBox: RSMBoundingBox) throws {
        self.device = device

        commandQueue = device.makeCommandQueue()!

        let library = device.makeDefaultLibrary()!
        modelRenderer = try ModelRenderer(device: device, library: library, meshes: meshes)

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

        camera.update(size: view.bounds.size)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_translate(modelMatrix, [0, -boundingBox.range[1] * 0.1, -boundingBox.range[1] * 0.5 - 5])
        modelMatrix = matrix_rotate(modelMatrix, radians(15), [1, 0, 0])
        modelMatrix = matrix_rotate(modelMatrix, Float(radians(time * 360 / 8)), [0, 1, 0])

        let viewMatrix = simd_float4x4(camera.viewMatrix)
        let projectionMatrix = simd_float4x4(camera.projectionMatrix)

        let normalMatrix = simd_float3x3(modelMatrix).inverse.transpose

        modelRenderer.render(
            atTime: time,
            device: device,
            renderPassDescriptor: renderPassDescriptor,
            commandBuffer: commandBuffer,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
