//
//  WaterRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//

import Metal
import simd
import ROShaders

class WaterRenderer {
    let renderPipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?

    let water: Water

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

    init(device: MTLDevice, library: MTLLibrary, water: Water) throws {
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

        self.water = water
    }

    func render(atTime time: CFTimeInterval,
                renderCommandEncoder: MTLRenderCommandEncoder,
                modelMatrix: simd_float4x4,
                viewMatrix: simd_float4x4,
                projectionMatrix: simd_float4x4) {

        let device = renderCommandEncoder.device

        let frame = Float(time * 60)

        guard water.mesh.vertices.count > 0, let vertexBuffer = device.makeBuffer(bytes: water.mesh.vertices, length: water.mesh.vertices.count * MemoryLayout<WaterVertex>.stride, options: []) else {
            return
        }

        var vertexUniforms = WaterVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            waveHeight: waveHeight,
            wavePitch: wavePitch,
            waterOffset: frame * waveSpeed.truncatingRemainder(dividingBy: 360) - 180
        )
        guard let vertexUniformsBuffer = device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<WaterVertexUniforms>.stride, options: []) else {
            return
        }

        var fragmentUniforms = WaterFragmentUniforms(
            fogUse: fog.use && fog.exist ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color,
            lightAmbient: light.ambient,
            lightDiffuse: light.diffuse,
            lightOpacity: light.opacity,
            opacity: waterOpacity
        )
        guard let fragmentUniformsBuffer = device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<WaterFragmentUniforms>.stride, options: []) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

        renderCommandEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        let texture = water.mesh.textures[Int(frame / animSpeed) % water.mesh.textures.count]
        renderCommandEncoder.setFragmentTexture(texture, index: 0)

        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: water.mesh.vertices.count)
    }
}
