//
//  MetalSelectionOverlayRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

#if os(iOS) || os(macOS)

import Metal
import QuartzCore
import RagnarokRenderers
import RagnarokResources
import RagnarokShaders
import simd

@MainActor
final class MetalSelectionOverlayRenderer {
    private var renderPipelineState: (any MTLRenderPipelineState)?
    private var depthStencilState: (any MTLDepthStencilState)?
    private var selectionTexture: (any MTLTexture)?
    private var vertices: [TileVertex] = []
    private var selectionShowTime: CFTimeInterval = -.infinity

    func prepare(device: any MTLDevice, resourceManager: ResourceManager) async {
        let path = ResourcePath.textureDirectory.appending(["grid.tga"])
        if let image = try? await resourceManager.image(at: path) {
            selectionTexture = MapMetalTextureFactory.makeTexture(
                from: image.cgImage,
                device: device,
                label: "tile-selector"
            )
        }

        let library = ragnarokShadersLibrary(device: device)!

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

        renderPipelineState = try? await device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }

    func syncSelection(_ selectedPosition: SIMD2<Int>?, mapGrid: MapGrid) {
        guard let pos = selectedPosition,
              0..<mapGrid.width ~= pos.x,
              0..<mapGrid.height ~= pos.y else {
            vertices = []
            return
        }

        let cell = mapGrid[pos]
        let x = Float(pos.x)
        let y = Float(pos.y)

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
        matrices: MapRuntimeRenderer.RenderMatrices
    ) {
        guard let renderPipelineState,
              let depthStencilState,
              let texture = selectionTexture,
              !vertices.isEmpty else {
            return
        }

        guard time - selectionShowTime < 0.5 else {
            return
        }

        let device = renderCommandEncoder.device

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
        renderCommandEncoder.setFragmentTexture(texture, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}

#endif
