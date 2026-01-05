//
//  Map.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/4.
//

import DataCompression
import Foundation

public enum MapGridError: Error {
    case dataCorrupted
}

public struct Map: Equatable, Hashable, Sendable {

    /// Map name.
    public var name: String

    /// Map index.
    public var index: Int

    /// X size.
    public var xs: Int16

    /// Y size.
    public var ys: Int16

    /// Cell data.
    public var data: [UInt8]

    init(name: String, index: Int, info: MapCache.MapInfo) {
        self.name = name
        self.index = index
        self.xs = info.xs
        self.ys = info.ys
        self.data = info.data
    }

    public func grid() async throws -> Map.Grid {
        let grid = try await Map.Grid(xs: xs, ys: ys, data: data)
        return grid
    }
}

extension Map {

    public struct Grid: Equatable, Hashable, Sendable {

        /// X size.
        public var xs: Int16

        /// Y size.
        public var ys: Int16

        /// Cells.
        public var cells: [Map.Cell]

        public init() {
            xs = 0
            ys = 0
            cells = []
        }

        init(xs: Int16, ys: Int16, data: [UInt8]) async throws {
            self.xs = xs
            self.ys = ys

            let decompressor = GzipDecompressor()
            let decompressedData = try await decompressor.unzip(bytes: data)

            guard decompressedData.count == Int(xs) * Int(ys) else {
                throw MapGridError.dataCorrupted
            }

            let cells = decompressedData.compactMap(Map.Cell.init)
            guard cells.count == Int(xs) * Int(ys) else {
                throw MapGridError.dataCorrupted
            }

            self.cells = cells
        }

        public func cellAt(x: Int16, y: Int16) -> Map.Cell {
            let index = Int(x) + Int(y) * Int(xs)
            let cell = cells[index]
            return cell
        }
    }

    public struct Cell: Equatable, Hashable, Sendable {

        public var isWalkable: Bool

        public var isShootable: Bool

        public var isWater: Bool

        init?(gatTileType: UInt8) {
            switch gatTileType {
            case 0: // walkable ground
                isWalkable = true
                isShootable = true
                isWater = false
            case 1: // non-walkable ground
                isWalkable = false
                isShootable = false
                isWater = false
            case 2: // ???
                isWalkable = true
                isShootable = true
                isWater = false
            case 3: // walkable water
                isWalkable = true
                isShootable = true
                isWater = true
            case 4: // ???
                isWalkable = true
                isShootable = true
                isWater = false
            case 5: // gap (snipable)
                isWalkable = false
                isShootable = true
                isWater = false
            case 6: // ???
                isWalkable = true
                isShootable = true
                isWater = false
            default:
                return nil
            }
        }
    }
}
