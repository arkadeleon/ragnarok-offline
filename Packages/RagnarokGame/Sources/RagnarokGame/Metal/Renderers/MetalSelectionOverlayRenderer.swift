//
//  MetalSelectionOverlayRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import QuartzCore
import RagnarokMetalRendering
import RagnarokShaders
import simd

@MainActor
final class MetalSelectionOverlayRenderer {
    private let device: any MTLDevice
    private let renderPipelineState: any MTLRenderPipelineState
    private let depthStencilState: (any MTLDepthStencilState)?

    private var vertices: [TileVertex] = []
    private let selectionTexture: any MTLTexture
    private var selectionShowTime: CFTimeInterval = -.infinity

    init(device: any MTLDevice, selectionTexture: any MTLTexture) throws {
        self.device = device

        let library = RagnarokShadersLibrary(device)!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "tileVertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "tileFragmentShader")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)

        self.selectionTexture = selectionTexture
    }

    func syncSelection(_ selectedPosition: SIMD2<Int>?, mapGrid: MapGrid) {
        guard let position = selectedPosition, mapGrid.contains(position) else {
            vertices = []
            return
        }

        let cell = mapGrid[position]
        let x = Float(position.x)
        let y = Float(position.y)

        // +0.1 vertical offset keeps the overlay above the tile surface.
        let p0 = SIMD3<Float>(x, cell.bottomLeftAltitude + 0.1, -y)
        let p1 = SIMD3<Float>(x + 1, cell.bottomRightAltitude + 0.1, -y)
        let p2 = SIMD3<Float>(x + 1, cell.topRightAltitude + 0.1, -(y + 1))
        let p3 = SIMD3<Float>(x, cell.topLeftAltitude + 0.1, -(y + 1))

        vertices = [
            TileVertex(position: p0, textureCoordinate: [0, 0]),
            TileVertex(position: p1, textureCoordinate: [1, 0]),
            TileVertex(position: p2, textureCoordinate: [1, 1]),
            TileVertex(position: p2, textureCoordinate: [1, 1]),
            TileVertex(position: p3, textureCoordinate: [0, 1]),
            TileVertex(position: p0, textureCoordinate: [0, 0]),
        ]
        selectionShowTime = CACurrentMediaTime()
    }

    func render(
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MetalMapRenderer.RenderMatrices
    ) {
        guard !vertices.isEmpty else {
            return
        }

        guard time - selectionShowTime < 0.5 else {
            return
        }

        var vertices = vertices
        guard let vertexBuffer = device.makeBuffer(
            bytes: &vertices,
            length: vertices.count * MemoryLayout<TileVertex>.stride,
            options: []
        ) else {
            return
        }

        var uniforms = TileVertexUniforms(
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix
        )
        guard let uniformsBuffer = device.makeBuffer(
            bytes: &uniforms,
            length: MemoryLayout<TileVertexUniforms>.stride,
            options: []
        ) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
        renderCommandEncoder.setFragmentTexture(selectionTexture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}
