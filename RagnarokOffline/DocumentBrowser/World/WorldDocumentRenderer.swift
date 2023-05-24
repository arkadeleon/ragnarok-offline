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

    init(altitude: Altitude, vertices: [GroundVertex], texture: Data?, waterVertices: [WaterVertex], waterTextures: [Data?], modelMeshes: [[ModelVertex]], modelTextures: [Data?]) throws {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!

        let library = device.makeDefaultLibrary()!
        groundRenderer = try GroundRenderer(device: device, library: library, vertices: vertices, texture: texture)
        waterRenderer = try WaterRenderer(device: device, library: library, vertices: waterVertices, textures: waterTextures)
        modelRenderer = try ModelRenderer(device: device, library: library, meshes: modelMeshes, textures: modelTextures)

        let target: simd_float3 = [
            Float(altitude.width) / 2,
            Float(altitude.height) / 2,
            altitude.heightForCell(atX: altitude.width / 2, y: altitude.height / 2)
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
