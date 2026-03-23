//
//  GroundRenderer.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2020/7/3.
//

import Metal
import RagnarokShaders
import simd

public final class GroundRenderer {
    let renderPipelineState: any MTLRenderPipelineState
    let depthStencilState: (any MTLDepthStencilState)?

    let ground: Ground
    let groundTexture: any MTLTexture

    let fog = Fog(
        use: false,
        exist: true,
        far: 30,
        near: 80,
        factor: 1,
        color: [1, 1, 1]
    )

    var light = Light(
        opacity: 1,
        ambient: [1, 1, 1],
        diffuse: [0, 0, 0],
        direction: [0, 1, 0]
    )

    init(device: any MTLDevice, library: any MTLLibrary, ground: Ground, groundTexture: any MTLTexture) throws {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "groundVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "groundFragmentShader")

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

        self.ground = ground
        self.groundTexture = groundTexture
    }

    public convenience init(device: any MTLDevice, ground: Ground, groundTexture: any MTLTexture, lighting: WorldLighting? = nil) throws {
        let library = RagnarokCreateShadersLibrary(device)!
        try self.init(device: device, library: library, ground: ground, groundTexture: groundTexture)
        if let lighting {
            updateLighting(lighting)
        }
    }

    public func updateLighting(_ lighting: WorldLighting) {
        light.ambient = lighting.ambient
        light.diffuse = lighting.diffuse
        light.direction = lighting.direction
        light.opacity = lighting.opacity
    }

    public func render(
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        normalMatrix: simd_float3x3
    ) {
        let device = renderCommandEncoder.device

        let vertices = ground.mesh.vertices
        guard vertices.count > 0, let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<GroundVertex>.stride, options: []) else {
            return
        }

        var vertexUniforms = GroundVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            lightDirection: light.direction,
            normalMatrix: normalMatrix
        )
        guard let vertexUniformsBuffer = device.makeBuffer(bytes: &vertexUniforms, length: MemoryLayout<GroundVertexUniforms>.stride, options: []) else {
            return
        }

        var fragmentUniforms = GroundFragmentUniforms(
            lightMapUse: 1,
            fogUse: fog.use && fog.exist ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color,
            lightAmbient: light.ambient,
            lightDiffuse: light.diffuse,
            lightOpacity: light.opacity
        )
        guard let fragmentUniformsBuffer = device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<GroundFragmentUniforms>.stride, options: []) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)

        renderCommandEncoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        renderCommandEncoder.setFragmentTexture(groundTexture, index: 0)
        renderCommandEncoder.setFragmentTexture(groundTexture, index: 1)
        renderCommandEncoder.setFragmentTexture(groundTexture, index: 2)

        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
