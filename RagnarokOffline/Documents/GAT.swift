//
//  GAT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

struct GAT: Encodable {
    var header: String
    var version: String
    var width: Int32
    var height: Int32
    var cells: [Cell] = []

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(4)
        guard header == "GRAT" else {
            throw DocumentError.invalidContents
        }

        let major: UInt8 = try reader.readInt()
        let minor: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        width = try reader.readInt()
        height = try reader.readInt()

        for _ in 0..<(width * height) {
            let cell = try Cell(from: reader)
            cells.append(cell)
        }
    }
}

extension GAT {
    enum CellType: Int32, Encodable {
        case walkable = 0
        case noWalkable = 1
        case noWalkableNoSnipable = 2
        case walkable2 = 3
        case unknown = 4
        case noWalkableSnipable = 5
        case walkable3 = 6
    }

    struct Cell: Encodable {
        var bottomLeft: Float
        var bottomRight: Float
        var topLeft: Float
        var topRight: Float
        var type: CellType

        init(from reader: BinaryReader) throws {
            bottomLeft = try reader.readFloat()
            bottomRight = try reader.readFloat()
            topLeft = try reader.readFloat()
            topRight = try reader.readFloat()
            type = try CellType(rawValue: reader.readInt()) ?? .walkable
        }
    }
}
