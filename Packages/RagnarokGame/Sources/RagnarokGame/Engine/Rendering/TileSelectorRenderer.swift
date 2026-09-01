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
            color: [1, 1, 1, 1],
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
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }

    /// Four corner brackets, each an L, sized as fractions of the tile.
    private func makeVertices(position: SIMD2<Int>, cell: MapGrid.Cell) -> [TileVertex] {
        let length: Float = 9 / 32
        let thickness: Float = 4 / 32

        // Cutting the L along the diagonal of its elbow leaves two congruent
        // trapezoids. Corners are offsets from the tile corner toward the middle,
        // and swapping u and v maps one trapezoid onto the other.
        let trapezoids: [(SIMD2<Float>, SIMD2<Float>, SIMD2<Float>, SIMD2<Float>)] = [
            ([0, 0], [length, 0], [length, thickness], [thickness, thickness]),
            ([0, 0], [thickness, thickness], [thickness, length], [0, length]),
        ]

        var vertices: [TileVertex] = []
        vertices.reserveCapacity(4 * trapezoids.count * 6)

        let corners: [SIMD2<Float>] = [[0, 0], [1, 0], [1, 1], [0, 1]]
        for corner in corners {
            let inward: SIMD2<Float> = [
                corner.x == 0 ? 1 : -1,
                corner.y == 0 ? 1 : -1,
            ]

            for (a, b, c, d) in trapezoids {
                vertices += makeQuad(
                    corner + inward * a,
                    corner + inward * b,
                    corner + inward * c,
                    corner + inward * d,
                    position: position,
                    cell: cell
                )
            }
        }

        return vertices
    }

    private func makeQuad(_ a: SIMD2<Float>, _ b: SIMD2<Float>, _ c: SIMD2<Float>, _ d: SIMD2<Float>, position: SIMD2<Int>, cell: MapGrid.Cell) -> [TileVertex] {
        let p0 = makePosition(a, position: position, cell: cell)
        let p1 = makePosition(b, position: position, cell: cell)
        let p2 = makePosition(c, position: position, cell: cell)
        let p3 = makePosition(d, position: position, cell: cell)

        return [
            TileVertex(position: p0),
            TileVertex(position: p1),
            TileVertex(position: p2),
            TileVertex(position: p2),
            TileVertex(position: p3),
            TileVertex(position: p0),
        ]
    }

    /// Turns a point in tile space, where (0, 0) is the tile's bottom left and
    /// (1, 1) its top right, into the space the model matrix expects. The altitude
    /// follows the same two triangles the ground is built from, so the brackets stay
    /// parallel to the surface on cells whose corners are not coplanar. The 0.1
    /// offset lifts them above it.
    private func makePosition(_ point: SIMD2<Float>, position: SIMD2<Int>, cell: MapGrid.Cell) -> SIMD3<Float> {
        let altitude = if point.y <= point.x {
            cell.bottomLeftAltitude
                + (cell.bottomRightAltitude - cell.bottomLeftAltitude) * point.x
                + (cell.topRightAltitude - cell.bottomRightAltitude) * point.y
        } else {
            cell.bottomLeftAltitude
                + (cell.topRightAltitude - cell.topLeftAltitude) * point.x
                + (cell.topLeftAltitude - cell.bottomLeftAltitude) * point.y
        }

        return SIMD3<Float>(
            Float(position.x) + point.x,
            -(altitude + 0.1),
            Float(position.y) + point.y
        )
    }
}
