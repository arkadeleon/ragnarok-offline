//
//  GATDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

struct GATCell {
    var height1: Float
    var height2: Float
    var height3: Float
    var height4: Float
    var types: GATCellType
}

struct GATCellType: OptionSet {
    let rawValue: UInt

    static let none = GATCellType(rawValue: 1 << 0)
    static let walkable = GATCellType(rawValue: 1 << 1)
    static let water = GATCellType(rawValue: 1 << 2)
    static let snipable = GATCellType(rawValue: 1 << 3)

    init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    init(rawType: UInt32) {
        switch rawType {
        case 0: self = [.walkable, .snipable]           // walkable ground
        case 1: self = [.none]                          // non-walkable ground
        case 2: self = [.walkable, .snipable]           // ???
        case 3: self = [.walkable, .snipable, .water]   // walkable water
        case 4: self = [.walkable, .snipable]           // ???
        case 5: self = [.snipable]                      // gat (snipable)
        case 6: self = [.walkable, .snipable]           // ???
        default: self = []
        }
    }
}

struct GATDocument {
    var header: String
    var version: String
    var width: UInt32
    var height: UInt32
    var cells: [GATCell]

    init(data: Data) throws {
        var buffer = ByteBuffer(data: data)

        header = try buffer.readString(length: 4)
        guard header == "GRAT" else {
            throw DocumentError.invalidContents
        }

        let major = try buffer.readUInt8()
        let minor = try buffer.readUInt8()
        version = "\(major).\(minor)"

        width = try buffer.readUInt32()
        height = try buffer.readUInt32()

        cells = try (0..<(width * height)).map { _ in
            try GATCell(
                height1: buffer.readFloat32() * 0.2,
                height2: buffer.readFloat32() * 0.2,
                height3: buffer.readFloat32() * 0.2,
                height4: buffer.readFloat32() * 0.2,
                types: GATCellType(rawType: buffer.readUInt32())
            )
        }
    }
}

extension GATDocument {
    func heightForCell(atX x: Int, y: Int) -> Float {
        let index = x + y * Int(width)
        let cell = cells[index]

        let x1 = cell.height1 + (cell.height2 - cell.height1) / 2
        let x2 = cell.height3 + (cell.height4 - cell.height3) / 2

        return -(x1 + (x2 - x1) / 2)
    }
}
