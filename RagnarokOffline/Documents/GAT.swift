//
//  GAT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

struct GAT {
    var header: Header
    var width: UInt32
    var height: UInt32
    var cells: [Cell] = []

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try Header(from: reader)

        width = try reader.readInt()
        height = try reader.readInt()

        for _ in 0..<(width * height) {
            let cell = try Cell(from: reader)
            cells.append(cell)
        }
    }
}

extension GAT {
    struct Header {
        var magic: String
        var version: String

        init(from reader: BinaryReader) throws {
            magic = try reader.readString(4)
            guard magic == "GRAT" else {
                throw DocumentError.invalidContents
            }

            let major: UInt8 = try reader.readInt()
            let minor: UInt8 = try reader.readInt()
            version = "\(major).\(minor)"
        }
    }
}

extension GAT {
    enum CellType: Int32 {
        case walkable = 0
        case noWalkable = 1
        case noWalkableNoSnipable = 2
        case walkable2 = 3
        case unknown = 4
        case noWalkableSnipable = 5
        case walkable3 = 6
    }

    struct Cell {
        var bottomLeft: Float
        var bottomRight: Float
        var topLeft: Float
        var topRight: Float
        var type: CellType?

        init(from reader: BinaryReader) throws {
            bottomLeft = try reader.readFloat() * 0.2
            bottomRight = try reader.readFloat() * 0.2
            topLeft = try reader.readFloat() * 0.2
            topRight = try reader.readFloat() * 0.2
            type = try CellType(rawValue: reader.readInt())
        }
    }
}

extension GAT {
    func height(forCellAtX x: Int, y: Int) -> Float {
        let index = x + y * Int(width)
        let cell = cells[index]

        let x1 = cell.bottomLeft + (cell.bottomRight - cell.bottomLeft) / 2
        let x2 = cell.topLeft + (cell.topRight - cell.topLeft) / 2

        return -(x1 + (x2 - x1) / 2)
    }
}
