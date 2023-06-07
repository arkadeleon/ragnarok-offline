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
    let texture: MTLTexture

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

        let textureLoaader = MTKTextureLoader(device: device)
        let image = UIImage(named: "wall.jpg")!
        texture = try! textureLoaader.newTexture(cgImage: image.cgImage!, options: nil)

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

        render(encoder: renderCommandEncoder, size: view.bounds.size)

        renderCommandEncoder.endEncoding()

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    func render(encoder: MTLRenderCommandEncoder, size: CGSize) {
        let vertices = [
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [ 0.5, -0.5, -0.5], textureCoordinate: [1.0, 0.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [ 0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [ 0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [-0.5,  0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [-0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [ 0.5, -0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [-0.5,  0.5,  0.5], textureCoordinate: [0.0, 1.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [-0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [-0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [-0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [-0.5,  0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [-0.5,  0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [-0.5,  0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0,  1.0,  0.0])
        ]
        let vertexBuffer = encoder.device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])!
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        let time = Float(CACurrentMediaTime())

        scene.camera.update(size: size)

        let model = matrix_rotate(matrix_identity_float4x4, time, [0.5, 1, 0])

        let normal = simd_float3x3(model.inverse.transpose)

        let view = simd_float4x4(scene.camera.viewMatrix)

        let projection = simd_float4x4(scene.camera.projectionMatrix)

        var uniforms = VertexUniforms(
            model: model,
            normal: normal,
            view: view,
            projection: projection
        )
        let uniformsBuffer = encoder.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<VertexUniforms>.stride, options: [])!
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)

        var fragmentUniforms = FragmentUniforms(
            lightPosition: [0, 5, 0]
        )
        let fragmentUniformsBuffer = encoder.device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, options: [])!
        encoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        encoder.setFragmentTexture(texture, index: 0)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
