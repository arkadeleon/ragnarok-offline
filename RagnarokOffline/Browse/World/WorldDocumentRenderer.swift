//
//  WorldDocumentRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit

class WorldDocumentRenderer: NSObject, Renderer {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let groundRenderer: GroundRenderer
    let waterRenderer: WaterRenderer
    let modelRenderer: ModelRenderer

    let camera: WorldDocumentCamera

    init(gat: GATDocument, vertices: [GroundVertex], texture: Data?, waterVertices: [WaterVertex], waterTextures: [Data?], modelMeshes: [[ModelVertex]], modelTextures: [Data?]) throws {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!

        let library = device.makeDefaultLibrary()!
        groundRenderer = try GroundRenderer(device: device, library: library, vertices: vertices, texture: texture)
        waterRenderer = try WaterRenderer(device: device, library: library, vertices: waterVertices, textures: waterTextures)
        modelRenderer = try ModelRenderer(device: device, library: library, meshes: modelMeshes, textures: modelTextures)

        let target: simd_float3 = [
            Float(gat.width) / 2,
            Float(gat.height) / 2,
            gat.heightForCell(atX: Int(gat.width / 2), y: Int(gat.height / 2))
        ]
        camera = WorldDocumentCamera(target: target)
        camera.altitudeTo = -200
        camera.zoomFinal = 200

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

        camera.update(time: time)

        let modelviewMatrix = camera.modelviewMatrix
        let projectionMatrix = perspective(radians(camera.zoom), Float(view.bounds.width / view.bounds.height), 1, 1000)
        let normalMatrix = camera.normalMatrix

        groundRenderer.render(
            atTime: time,
            device: device,
            renderPassDescriptor: renderPassDescriptor,
            commandBuffer: commandBuffer,
            modelviewMatrix: modelviewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        renderPassDescriptor.colorAttachments[0].loadAction = .load

        waterRenderer.render(
            atTime: time,
            device: device,
            renderPassDescriptor: renderPassDescriptor,
            commandBuffer: commandBuffer,
            modelviewMatrix: modelviewMatrix,
            projectionMatrix: projectionMatrix
        )

        renderPassDescriptor.colorAttachments[0].loadAction = .load

        modelRenderer.render(
            atTime: time,
            device: device,
            renderPassDescriptor: renderPassDescriptor,
            commandBuffer: commandBuffer,
            modelMatrix: modelviewMatrix,
            viewMatrix: matrix_identity_float4x4,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}