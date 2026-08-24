//
//  TileSelectorRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Foundation
import Metal
import QuartzCore
import RagnarokRendering
import RagnarokShaders
import simd

final class TileSelectorRenderer {
    let device: any MTLDevice

    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "tileVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "tileFragmentShader")
        renderPipelineDescriptor.maxVertexAmplificationCount = configuration.amplificationCount
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = configuration.colorPixelFormat
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.depthAttachmentPixelFormat = configuration.depthStencilPixelFormat
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = configuration.depthCompareFunction
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func render(
        tileSelector: MapSceneRenderSnapshot.TileSelector,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        let vertices = makeVertices(position: tileSelector.position, cell: tileSelector.cell)

        var vertexUniforms = TileVertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix
        )

        var fragmentUniforms = TileFragmentUniforms(
            fogUse: fog.isEnabled ? 1 : 0,
            fogNear: fog.near,
            fogFar: fog.far,
            fogColor: fog.color
        )

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        vertices.withUnsafeBytes { bytes in
            renderCommandEncoder.setVertexBytes(bytes.baseAddress!, length: bytes.count, index: 0)
        }
        renderCommandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<TileVertexUniforms>.stride,
            index: 1
        )
        renderCommandEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<TileFragmentUniforms>.stride,
            index: 0
        )
        renderCommandEncoder.setFragmentTexture(tileSelector.texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }

    private func makeVertices(position: SIMD2<Int>, cell: MapGrid.Cell) -> [TileVertex] {
        let x = Float(position.x)
        let y = Float(position.y)

        // The model matrix turns these into render space. The +0.1 vertical offset
        // keeps the overlay above the tile surface.
        let p0 = SIMD3<Float>(x, -(cell.bottomLeftAltitude + 0.1), y)
        let p1 = SIMD3<Float>(x + 1, -(cell.bottomRightAltitude + 0.1), y)
        let p2 = SIMD3<Float>(x + 1, -(cell.topRightAltitude + 0.1), y + 1)
        let p3 = SIMD3<Float>(x, -(cell.topLeftAltitude + 0.1), y + 1)

        return [
            TileVertex(position: p0, textureCoordinate: [0, 0]),
            TileVertex(position: p1, textureCoordinate: [1, 0]),
            TileVertex(position: p2, textureCoordinate: [1, 1]),
            TileVertex(position: p2, textureCoordinate: [1, 1]),
            TileVertex(position: p3, textureCoordinate: [0, 1]),
            TileVertex(position: p0, textureCoordinate: [0, 0]),
        ]
    }
}
