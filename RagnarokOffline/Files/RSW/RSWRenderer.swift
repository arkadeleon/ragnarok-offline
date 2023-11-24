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

    let target: simd_float3

    init(device: MTLDevice, gat: GAT, groundMeshes: [GroundMesh], waterMesh: WaterMesh, modelMeshes: [ModelMesh]) throws {
        self.device = device

        commandQueue = device.makeCommandQueue()!

        let library = device.makeDefaultLibrary()!
        groundRenderer = try GroundRenderer(device: device, library: library, meshes: groundMeshes)
        waterRenderer = try WaterRenderer(device: device, library: library, mesh: waterMesh)
        modelRenderer = try ModelRenderer(device: device, library: library, meshes: modelMeshes)

        target = [
            Float(gat.width) / 2,
            Float(gat.height) / 2,
            gat.height(forCellAtX: Int(gat.width / 2), y: Int(gat.height / 2)) / 5
        ]

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

        let scale = 1 / max(target.x, target.y)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_scale(modelMatrix, [scale, scale, scale])
        modelMatrix = matrix_translate(modelMatrix, [-target.x, -target.y, -target.z])
        modelMatrix = matrix_rotate(modelMatrix, radians(270), [1, 0, 0])

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix

        let normalMatrix = simd_float3x3(modelMatrix).inverse.transpose

        groundRenderer.render(
            atTime: time,
            device: device,
            renderPassDescriptor: renderPassDescriptor,
            commandBuffer: commandBuffer,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        renderPassDescriptor.colorAttachments[0].loadAction = .load

        waterRenderer.render(
            atTime: time,
            device: device,
            renderPassDescriptor: renderPassDescriptor,
            commandBuffer: commandBuffer,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix
        )

        renderPassDescriptor.colorAttachments[0].loadAction = .load

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
