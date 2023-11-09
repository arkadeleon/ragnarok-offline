//
//  GNDDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

struct GNDLightmap {

    var per_cell: Int32
    var count: UInt32
    var data: [UInt8]
}

struct GNDTile {

    var u1: Float
    var u2: Float
    var u3: Float
    var u4: Float
    var v1: Float
    var v2: Float
    var v3: Float
    var v4: Float
    var texture: UInt16
    var light: UInt16
    var color: simd_uchar4

    init(from reader: BinaryReader, textures: [String], textureIndexes: [UInt16]) throws {
        u1 = try reader.readFloat()
        u2 = try reader.readFloat()
        u3 = try reader.readFloat()
        u4 = try reader.readFloat()
        v1 = try reader.readFloat()
        v2 = try reader.readFloat()
        v3 = try reader.readFloat()
        v4 = try reader.readFloat()
        texture = try reader.readInt()
        light = try reader.readInt()
        color = try [reader.readInt(), reader.readInt(), reader.readInt(), reader.readInt()]

        texture = textureIndexes[Int(texture)]

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

        let u   = Float(Int(texture) % Int(ATLAS_COLS))
        let v   = floorf(Float(texture) / ATLAS_COLS)
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

struct GNDSurface {

    var height: simd_float4
    var tile_up: Int32
    var tile_front: Int32
    var tile_right: Int32

    init(from reader: BinaryReader) throws {
        height = try [
            reader.readFloat() / 5,
            reader.readFloat() / 5,
            reader.readFloat() / 5,
            reader.readFloat() / 5
        ]
        tile_up = try reader.readInt()
        tile_front = try reader.readInt()
        tile_right = try reader.readInt()
    }
}

struct GNDDocument {

    var header: String
    var version: String
    var width: UInt32
    var height: UInt32
    var zoom: Float

    var textures: [String]
    var textureIndexes: [UInt16]

    var lightmap: GNDLightmap

    var tiles: [GNDTile]
    var surfaces: [GNDSurface]

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(4)
        guard header == "GRGN" else {
            throw DocumentError.invalidContents
        }

        let major: UInt8 = try reader.readInt()
        let minor: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        width = try reader.readInt()
        height = try reader.readInt()
        zoom = try reader.readFloat()

        (textures, textureIndexes) = try GNDDocument.loadTextures(reader: reader)
        lightmap = try GNDDocument.loadLightmap(reader: reader)

        tiles = try GNDDocument.loadTiles(reader: reader, textures: textures, textureIndexes: textureIndexes)
        surfaces = try GNDDocument.loadSurfaces(reader: reader, width: width, height: height)
    }

    private static func loadTextures(reader: BinaryReader) throws -> (textures: [String], indexes: [UInt16]) {
        let count: UInt32 = try reader.readInt()
        let length: UInt32 = try reader.readInt()

        var indexes: [UInt16] = []
        var textures: [String] = []

        for _ in 0..<count {
            let texture = try reader.readString(Int(length), encoding: .koreanEUC)
            var pos = textures.firstIndex(of: texture) ?? -1

            if pos == -1 {
                textures.append(texture)
                pos = textures.count - 1
            }

            indexes.append(UInt16(pos))
        }

        return (textures, indexes)
    }

    private static func loadLightmap(reader: BinaryReader) throws -> GNDLightmap {
        let count: UInt32 = try reader.readInt()
        let per_cell_x: Int32 = try reader.readInt()
        let per_cell_y: Int32 = try reader.readInt()
        let size_cell: Int32 = try reader.readInt()
        let per_cell = per_cell_x * per_cell_y * size_cell

        let lightmap = try GNDLightmap(
            per_cell: per_cell,
            count: count,
            data: reader.readBytes(Int(count) * Int(per_cell) * 4)
        )
        return lightmap
    }

    private static func loadTiles(reader: BinaryReader, textures: [String], textureIndexes: [UInt16]) throws -> [GNDTile] {
        let count: UInt32 = try reader.readInt()
        var tiles: [GNDTile] = []

        for _ in 0..<count {
            let tile = try GNDTile(from: reader, textures: textures, textureIndexes: textureIndexes)
            tiles.append(tile)
        }

        return tiles
    }

    private static func loadSurfaces(reader: BinaryReader, width: UInt32, height: UInt32) throws -> [GNDSurface] {
        let count = width * height
        var surfaces: [GNDSurface] = []

        for _ in 0..<count {
            let surface = try GNDSurface(from: reader)
            surfaces.append(surface)
        }

        return surfaces
    }
}
