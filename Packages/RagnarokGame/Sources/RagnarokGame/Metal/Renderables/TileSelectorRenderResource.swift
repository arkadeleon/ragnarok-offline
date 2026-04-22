//
//  TileSelectorRenderResource.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/22.
//

import CoreGraphics
import Metal
import QuartzCore
import RagnarokMetalRendering
import RagnarokShaders
import simd

final class TileSelectorRenderResource {
    private let device: any MTLDevice

    private(set) var vertexCount: Int = 0
    private(set) var vertexBuffer: (any MTLBuffer)?

    private(set) var selectionTexture: (any MTLTexture)?
    private(set) var selectionShowTime: CFTimeInterval = -.infinity

    init(device: any MTLDevice, image: CGImage? = nil) {
        self.device = device

        selectionTexture = image.flatMap {
            MetalTextureFactory.makeTexture(
                from: $0,
                device: device,
                label: "tile-selector"
            )
        }
    }

    func syncSelection(_ selectedPosition: SIMD2<Int>?, mapGrid: MapGrid) {
        guard let position = selectedPosition, mapGrid.contains(position) else {
            clearSelection()
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

        let vertices = [
            TileVertex(position: p0, textureCoordinate: [0, 0]),
            TileVertex(position: p1, textureCoordinate: [1, 0]),
            TileVertex(position: p2, textureCoordinate: [1, 1]),
            TileVertex(position: p2, textureCoordinate: [1, 1]),
            TileVertex(position: p3, textureCoordinate: [0, 1]),
            TileVertex(position: p0, textureCoordinate: [0, 0]),
        ]

        vertexCount = vertices.count
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<TileVertex>.stride,
            options: []
        )

        if vertexBuffer != nil {
            selectionShowTime = CACurrentMediaTime()
        } else {
            clearSelection()
        }
    }

    private func clearSelection() {
        vertexCount = 0
        vertexBuffer = nil
    }
}
