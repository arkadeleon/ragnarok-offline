//
//  GameRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit

class GameRenderer: NSObject, Renderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let colorPixelFormat: MTLPixelFormat
    let depthStencilPixelFormat: MTLPixelFormat
    let renderPipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState

    lazy var scene = GameScene(device: device)

    override init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        let library = device.makeDefaultLibrary()!
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")

        colorPixelFormat = .bgra8Unorm
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat

        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        depthStencilPixelFormat = .depth32Float
        renderPipelineDescriptor.depthAttachmentPixelFormat = depthStencilPixelFormat

        renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true

        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!

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

        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        renderPassDescriptor.depthAttachment.clearDepth = 1

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        for model in scene.models {
            render(model, encoder: renderCommandEncoder, size: view.bounds.size)
        }

        renderCommandEncoder.endEncoding()

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    func render(_ model: Model3D, encoder: MTLRenderCommandEncoder, size: CGSize) {
        let time = Float(CACurrentMediaTime())

        scene.camera.update(size: size)

        let modelMatrix = matrix_rotate(matrix_identity_float4x4, time, [0.5, 1, 0])
        let normal = simd_float3x3(modelMatrix.inverse.transpose)
        let viewMatrix = simd_float4x4(scene.camera.viewMatrix)
        let projectionMatrix = simd_float4x4(scene.camera.projectionMatrix)

        var uniforms = VertexUniforms(
            model: modelMatrix,
            normal: normal,
            view: viewMatrix,
            projection: projectionMatrix
        )

        var fragmentUniforms = FragmentUniforms(
            lightPosition: [0, 5, 0]
        )

        for mesh in model.meshes {
            for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
                encoder.setVertexBuffer(vertexBuffer, offset: 0, index: index)
            }

            let uniformsBuffer = encoder.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<VertexUniforms>.stride)!
            encoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)

            let fragmentUniformsBuffer = encoder.device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride)!
            encoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

            for submesh in mesh.submeshes {
                encoder.setFragmentTexture(submesh.texture, index: 0)

                encoder.drawIndexedPrimitives(
                    type: submesh.primitiveType,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer,
                    indexBufferOffset: submesh.indexBufferOffset
                )
            }
        }
    }
}
