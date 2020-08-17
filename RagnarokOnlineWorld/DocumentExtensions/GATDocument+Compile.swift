//
//  GATDocument+Compile.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

struct Altitude {

    var width: Int
    var height: Int
    private var cells: [GATCell]

    init(width: Int, height: Int, cells: [GATCell]) {
        self.width = width
        self.height = height
        self.cells = cells
    }

    func heightForCell(atX x: Int, y: Int) -> Float {
        let index = x + y * width
        let cell = cells[index]

        let x1 = cell.height1 + (cell.height2 - cell.height1) / 2
        let x2 = cell.height3 + (cell.height4 - cell.height3) / 2

        return -(x1 + (x2 - x1) / 2)
    }
}

extension GATDocument {

    func compile() -> Altitude {
        return Altitude(
            width: Int(width),
            height: Int(height),
            cells: cells
        )
    }
}
