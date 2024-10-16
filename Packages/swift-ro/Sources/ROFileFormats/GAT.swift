//
//  GAT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/16.
//

import Foundation
import ROCore

public struct GAT {
    public var header: String
    public var version: String
    public var width: Int32
    public var height: Int32
    public var tiles: [Tile] = []

    public init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(4)
        guard header == "GRAT" else {
            throw FileFormatError.invalidHeader(header, expected: "GRAT")
        }

        let major: UInt8 = try reader.readInt()
        let minor: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        width = try reader.readInt()
        height = try reader.readInt()

        for _ in 0..<(width * height) {
            let tile = try Tile(from: reader)
            tiles.append(tile)
        }
    }
}

extension GAT {
    public enum TileType: Int32 {
        case walkable = 0
        case noWalkable = 1
        case noWalkableNoSnipable = 2
        case walkable2 = 3
        case unknown = 4
        case noWalkableSnipable = 5
        case walkable3 = 6
    }

    public struct Tile {
        public var bottomLeftAltitude: Float
        public var bottomRightAltitude: Float
        public var topLeftAltitude: Float
        public var topRightAltitude: Float
        public var type: TileType

        init(from reader: BinaryReader) throws {
            bottomLeftAltitude = try reader.readFloat()
            bottomRightAltitude = try reader.readFloat()
            topLeftAltitude = try reader.readFloat()
            topRightAltitude = try reader.readFloat()
            type = try TileType(rawValue: reader.readInt()) ?? .walkable
        }
    }
}

extension GAT {
    public func tile(atX x: Int, y: Int) -> GAT.Tile {
        let index = x + y * Int(width)
        let tile = tiles[index]
        return tile
    }
}

extension GAT.Tile {
    public var averageAltitude: Float {
        (bottomLeftAltitude + bottomRightAltitude + topLeftAltitude + topRightAltitude) / 4
    }
}
