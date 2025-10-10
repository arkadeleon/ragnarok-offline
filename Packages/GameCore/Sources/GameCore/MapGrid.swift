//
//  MapGrid.swift
//  GameCore
//
//  Created by Leon Li on 2025/10/10.
//

import FileFormats

struct MapGrid {
    var width: Int
    var height: Int

    struct Cell {
        var altitude: Float
        var isWalkable: Bool
    }

    private var cells: [MapGrid.Cell] = []

    init(gat: GAT) {
        width = Int(gat.width)
        height = Int(gat.height)

        for y in 0..<height {
            for x in 0..<width {
                let tile = gat.tileAt(x: x, y: y)
                let cell = MapGrid.Cell(altitude: tile.averageAltitude, isWalkable: tile.isWalkable)
                cells.append(cell)
            }
        }
    }

    subscript(position: SIMD2<Int>) -> MapGrid.Cell {
        let index = position.x + position.y * width
        return cells[index]
    }
}
