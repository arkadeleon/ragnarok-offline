//
//  GND.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

struct GND {
    var header: Header
    var width: UInt32
    var height: UInt32
    var zoom: Float

    var textures: [String] = []
    var textureIndexes: [UInt16] = []

    var lightmap: GNDLightmap

    var tiles: [Tile] = []

    var surfaces: [Surface] = []

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try Header(from: reader)

        width = try reader.readInt()
        height = try reader.readInt()
        zoom = try reader.readFloat()

        let textureCount: UInt32 = try reader.readInt()
        let textureNameLength: UInt32 = try reader.readInt()

        for _ in 0..<textureCount {
            let texture = try reader.readString(Int(textureNameLength), encoding: .koreanEUC)

            var index = textures.firstIndex(of: texture) ?? -1
            if index == -1 {
                textures.append(texture)
                index = textures.count - 1
            }

            textureIndexes.append(UInt16(index))
        }

        let count: UInt32 = try reader.readInt()
        let per_cell_x: Int32 = try reader.readInt()
        let per_cell_y: Int32 = try reader.readInt()
        let size_cell: Int32 = try reader.readInt()
        let per_cell = per_cell_x * per_cell_y * size_cell

        lightmap = try GNDLightmap(
            per_cell: per_cell,
            count: count,
            data: reader.readBytes(Int(count) * Int(per_cell) * 4)
        )

        let tileCount: UInt32 = try reader.readInt()
        for _ in 0..<tileCount {
            let tile = try Tile(from: reader, textures: textures, textureIndexes: textureIndexes)
            tiles.append(tile)
        }

        let surfaceCount = width * height
        for _ in 0..<surfaceCount {
            let surface = try Surface(from: reader)
            surfaces.append(surface)
        }
    }
}

extension GND {
    struct Header {
        var magic: String
        var version: String

        init(from reader: BinaryReader) throws {
            magic = try reader.readString(4)
            guard magic == "GRGN" else {
                throw DocumentError.invalidContents
            }

            let major: UInt8 = try reader.readInt()
            let minor: UInt8 = try reader.readInt()
            version = "\(major).\(minor)"
        }
    }
}

extension GND {
    struct GNDLightmap {
        var per_cell: Int32
        var count: UInt32
        var data: [UInt8]
    }
}

extension GND {
    struct Tile {
        typealias Color = (alpha: UInt8, red: UInt8, green: UInt8, blue: UInt8)

        var u1: Float
        var u2: Float
        var u3: Float
        var u4: Float
        var v1: Float
        var v2: Float
        var v3: Float
        var v4: Float
        var textureIndex: UInt16
        var lightmapIndex: UInt16
        var color: Color

        init(from reader: BinaryReader, textures: [String], textureIndexes: [UInt16]) throws {
            u1 = try reader.readFloat()
            u2 = try reader.readFloat()
            u3 = try reader.readFloat()
            u4 = try reader.readFloat()
            v1 = try reader.readFloat()
            v2 = try reader.readFloat()
            v3 = try reader.readFloat()
            v4 = try reader.readFloat()

            textureIndex = try reader.readInt()
            lightmapIndex = try reader.readInt()

            let alpha: UInt8 = try reader.readInt()
            let red: UInt8 = try reader.readInt()
            let green: UInt8 = try reader.readInt()
            let blue: UInt8 = try reader.readInt()
            color = (alpha, red, green, blue)

            textureIndex = textureIndexes[Int(textureIndex)]

            generateAtlas(textures: textures)
        }

        private mutating func generateAtlas(textures: [String]) {
            let ATLAS_COLS         = roundf(sqrtf(Float(textures.count)))
            let ATLAS_ROWS         = ceilf(sqrtf(Float(textures.count)))
            let ATLAS_WIDTH        = powf(2, ceilf(logf(ATLAS_COLS * 258) / logf(2)))
            let ATLAS_HEIGHT       = powf(2, ceilf(logf(ATLAS_ROWS * 258) / logf(2)))
            let ATLAS_FACTOR_U     = (ATLAS_COLS * 258) / ATLAS_WIDTH
            let ATLAS_FACTOR_V     = (ATLAS_ROWS * 258) / ATLAS_HEIGHT
            let ATLAS_PX_U         = Float(1) / Float(258)
            let ATLAS_PX_V         = Float(1) / Float(258)

            let u   = Float(Int(textureIndex) % Int(ATLAS_COLS))
            let v   = floorf(Float(textureIndex) / ATLAS_COLS)
            u1 = (u + u1 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
            u2 = (u + u2 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
            u3 = (u + u3 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
            u4 = (u + u4 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
            v1 = (v + v1 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
            v2 = (v + v2 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
            v3 = (v + v3 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
            v4 = (v + v4 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
        }
    }
}

extension GND {
    struct Surface {
        var bottomLeft: Float
        var bottomRight: Float
        var topLeft: Float
        var topRight: Float

        var tileUp: Int32
        var tileFront: Int32
        var tileRight: Int32

        init(from reader: BinaryReader) throws {
            bottomLeft = try reader.readFloat()
            bottomRight = try reader.readFloat()
            topLeft = try reader.readFloat()
            topRight = try reader.readFloat()

            tileUp = try reader.readInt()
            tileFront = try reader.readInt()
            tileRight = try reader.readInt()
        }
    }
}
