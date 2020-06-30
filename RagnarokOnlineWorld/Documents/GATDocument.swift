//
//  GATDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

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

class GATDocument: Document<GATDocument.Contents> {

    struct Contents {
        var header: String
        var version: String
        var width: UInt32
        var height: UInt32
        var cells: [GATCell]
    }

    static let typeTable: [UInt32: GATType] = [
        0: [.walkable, .snipable],          // walkable ground
        1: [.none],                         // non-walkable ground
        2: [.walkable, .snipable],          // ???
        3: [.walkable, .snipable, .water],  // walkable water
        4: [.walkable, .snipable],          // ???
        5: [.snipable],                     // gat (snipable)
        6: [.walkable, .snipable]           // ???
    ]

    override func load(from data: Data) throws -> Result<Contents, DocumentError> {
        let stream = DataStream(data: data)
        let reader = BinaryReader(stream: stream)

        do {
            let contents = try reader.readGATContents()
            return .success(contents)
        } catch {
            return .failure(.invalidContents)
        }
    }
}

extension BinaryReader {

    fileprivate func readGATContents() throws -> GATDocument.Contents {
        let header = try readString(count: 4)
        guard header == "GRAT" else {
            throw DocumentError.invalidContents
        }

        let major = try readUInt8()
        let minor = try readUInt8()
        let version = "\(major).\(minor)"

        let width = try readUInt32()
        let height = try readUInt32()

        var cells: [GATCell] = []
        for _ in 0..<(width * height) {
            let cell = try GATCell(
                height1: readFloat32() * 0.2,
                height2: readFloat32() * 0.2,
                height3: readFloat32() * 0.2,
                height4: readFloat32() * 0.2,
                types: GATDocument.typeTable[readUInt32()] ?? []
            )
            cells.append(cell)
        }

        let contents = GATDocument.Contents(
            header: header,
            version: version,
            width: width,
            height: height,
            cells: cells
        )
        return contents
    }
}
