//
//  WaterRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit
import SGLMath

class WaterRenderer {

    let renderPipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    let vertices: [WaterVertex]
    let textures: [MTLTexture?]

    var waveSpeed: Float = 0
    var waveHeight: Float = 0
    var wavePitch: Float = 0
    var waterLevel: Float = 0
    var animSpeed: Float = 1
    var waterOpacity: Float = 0.6

    let fog = Fog(
        use: false,
        exist: true,
        far: 30,
        near: 80,
        factor: 1,
        color: [1, 1, 1]
    )

    let light = Light(
        opacity: 1,
        ambient: [1, 1, 1],
        diffuse: [0, 0, 0],
        direction: [0, 1, 0]
    )

    init(device: MTLDevice, library: MTLLibrary, vertices: [WaterVertex], textures: [Data?]) throws {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "waterVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "waterFragmentShader")

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Formats.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        renderPipelineDescriptor.depthAttachmentPixelFormat = Formats.depthPixelFormat

        self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true

        self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        self.vertices = vertices

        let textureLoader = MTKTextureLoader(device: device)
        self.textures = try textures.map { data -> MTLTexture? in
            try data.flatMap { try textureLoader.newTexture(data: $0, options: nil) }
        }
    }

    func render(atTime time: CFTimeInterval,
                device: MTLDevice,
                renderCommandEncoder: MTLRenderCommandEncoder,
                modelviewMatrix: Matrix4x4<Float>,
                projectionMatrix: Matrix4x4<Float>) {

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        let frame = Float(time * 60)

        var vertexUniforms = WaterVertexUniforms(
            modelViewMat: modelviewMatrix.simd,
            projectionMat: projectionMatrix.simd,
            waveHeight: waveHeight,
            wavePitch: wavePitch,
            waterOffset: frame * waveSpeed.truncatingRemainder(dividingBy: 360) - 180
        )

        guard let vertexUniformsBuffer = device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<WaterVertexUniforms>.stride, options: []) else {
            return
        }

        renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

        var fragmentUniforms = WaterFragmentUniforms(
            fogUse: fog.use && fog.exist ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color.simd,
            lightAmbient: light.ambient.simd,
            lightDiffuse: light.diffuse.simd,
            lightOpacity: light.opacity,
            opacity: waterOpacity
        )

        guard let fragmentUniformsBuffer = device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<WaterFragmentUniforms>.stride, options: []) else {
            return
        }

        renderCommandEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        guard vertices.count > 0 else {
            return
        }

        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<WaterVertex>.stride, options: []) else {
            return
        }

        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        let texture = textures[Int(frame / animSpeed) % textures.count]
        renderCommandEncoder.setFragmentTexture(texture, index: 0)

        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
