//
//  GATDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

struct GATType: OptionSet {

    let rawValue: UInt

    init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    static let none = GATType(rawValue: 1 << 0)
    static let walkable = GATType(rawValue: 1 << 1)
    static let water = GATType(rawValue: 1 << 2)
    static let snipable = GATType(rawValue: 1 << 3)
}

struct GATCell {

    var height1: Float
    var height2: Float
    var height3: Float
    var height4: Float
    var types: GATType
}

struct GATDocument: Document {

    static let typeTable: [UInt32: GATType] = [
        0: [.walkable, .snipable],          // walkable ground
        1: [.none],                         // non-walkable ground
        2: [.walkable, .snipable],          // ???
        3: [.walkable, .snipable, .water],  // walkable water
        4: [.walkable, .snipable],          // ???
        5: [.snipable],                     // gat (snipable)
        6: [.walkable, .snipable]           // ???
    ]

    var header: String
    var version: String
    var width: UInt32
    var height: UInt32
    var cells: [GATCell]

    init(from stream: Stream) throws {
        let reader = StreamReader(stream: stream)

        header = try reader.readString(count: 4)
        guard header == "GRAT" else {
            throw DocumentError.invalidContents
        }

        let major = try reader.readUInt8()
        let minor = try reader.readUInt8()
        version = "\(major).\(minor)"

        width = try reader.readUInt32()
        height = try reader.readUInt32()

        var cells: [GATCell] = []
        for _ in 0..<(width * height) {
            let cell = try GATCell(
                height1: reader.readFloat32() * 0.2,
                height2: reader.readFloat32() * 0.2,
                height3: reader.readFloat32() * 0.2,
                height4: reader.readFloat32() * 0.2,
                types: GATDocument.typeTable[reader.readUInt32()] ?? []
            )
            cells.append(cell)
        }
        self.cells = cells
    }
}
