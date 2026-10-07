//
//  MapGrid.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/10/10.
//

import RagnarokFileFormats
import simd

struct MapGrid {
    var width: Int
    var height: Int

    struct Cell {
        var bottomLeftAltitude: Float
        var bottomRightAltitude: Float
        var topLeftAltitude: Float
        var topRightAltitude: Float
        var averageAltitude: Float
        var isWalkable: Bool
    }

    private var cells: [MapGrid.Cell] = []

    init(gat: GAT) {
        width = Int(gat.width)
        height = Int(gat.height)

        for y in 0..<height {
            for x in 0..<width {
                let tile = gat.tileAt(x: x, y: y)
                let cell = MapGrid.Cell(
                    bottomLeftAltitude: -tile.bottomLeftAltitude / 5,
                    bottomRightAltitude: -tile.bottomRightAltitude / 5,
                    topLeftAltitude: -tile.topLeftAltitude / 5,
                    topRightAltitude: -tile.topRightAltitude / 5,
                    averageAltitude: -tile.averageAltitude / 5,
                    isWalkable: tile.isWalkable
                )
                cells.append(cell)
            }
        }
    }

    subscript(position: SIMD2<Int>) -> MapGrid.Cell {
        let index = position.x + position.y * width
        return cells[index]
    }

    func contains(_ position: SIMD2<Int>) -> Bool {
        (0..<width).contains(position.x) && (0..<height).contains(position.y)
    }

    func worldPosition(for gridPosition: SIMD2<Int>) -> SIMD3<Float> {
        let altitude = self[gridPosition].averageAltitude
        return [
            Float(gridPosition.x) + 0.5,
            Float(gridPosition.y) + 0.5,
            altitude,
        ]
    }

    func worldPosition(at gridPoint: SIMD2<Float>) -> SIMD3<Float> {
        let point = gridPoint + 0.5
        let x = min(max(Int(point.x.rounded(.down)), 0), width - 1)
        let y = min(max(Int(point.y.rounded(.down)), 0), height - 1)
        let fraction = simd_clamp(point - SIMD2<Float>(Float(x), Float(y)), .zero, .one)

        let cell = self[SIMD2(x, y)]
        let bottomAltitude = cell.bottomLeftAltitude + (cell.bottomRightAltitude - cell.bottomLeftAltitude) * fraction.x
        let topAltitude = cell.topLeftAltitude + (cell.topRightAltitude - cell.topLeftAltitude) * fraction.x
        let altitude = bottomAltitude + (topAltitude - bottomAltitude) * fraction.y

        return [
            point.x,
            point.y,
            altitude,
        ]
    }
}
