//
//  GAT.swift
//  FileFormats
//
//  Created by Leon Li on 2020/5/16.
//

import BinaryIO
import Foundation

public struct GAT: FileFormat {
    public var header: String
    public var version: FileFormatVersion
    public var width: Int32
    public var height: Int32
    public var tiles: [GAT.Tile] = []

    public init(from decoder: BinaryDecoder) throws {
        header = try decoder.decode(String.self, lengthOfBytes: 4)
        guard header == "GRAT" else {
            throw FileFormatError.invalidHeader(header, expected: "GRAT")
        }

        let major = try decoder.decode(UInt8.self)
        let minor = try decoder.decode(UInt8.self)
        version = FileFormatVersion(major: major, minor: minor)

        width = try decoder.decode(Int32.self)
        height = try decoder.decode(Int32.self)

        for _ in 0..<(width * height) {
            let tile = try decoder.decode(GAT.Tile.self)
            tiles.append(tile)
        }
    }
}

extension GAT {
    public enum TileType: Int32, Sendable {
        case walkable = 0
        case noWalkable = 1
        case noWalkableNoSnipable = 2
        case walkable2 = 3
        case unknown = 4
        case noWalkableSnipable = 5
        case walkable3 = 6
    }

    public struct Tile: BinaryDecodable, Sendable {
        public var bottomLeftAltitude: Float
        public var bottomRightAltitude: Float
        public var topLeftAltitude: Float
        public var topRightAltitude: Float
        public var type: GAT.TileType

        public init(from decoder: BinaryDecoder) throws {
            bottomLeftAltitude = try decoder.decode(Float.self)
            bottomRightAltitude = try decoder.decode(Float.self)
            topLeftAltitude = try decoder.decode(Float.self)
            topRightAltitude = try decoder.decode(Float.self)

            let type = try GAT.TileType(rawValue: decoder.decode(Int32.self))
            self.type = type ?? .walkable
        }
    }
}

extension GAT {
    public func tileAt(x: Int, y: Int) -> GAT.Tile {
        let index = x + y * Int(width)
        let tile = tiles[index]
        return tile
    }
}

extension GAT.Tile {
    public var averageAltitude: Float {
        (bottomLeftAltitude + bottomRightAltitude + topLeftAltitude + topRightAltitude) / 4
    }

    public var isWalkable: Bool {
        switch type {
        case .walkable, .walkable2, .walkable3: true
        default: false
        }
    }
}
