//
//  GNDDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import SGLMath

struct GNDLightmap {

    var per_cell: Int32 = 0
    var count: UInt32 = 0
    var data = Data()
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
    var color: Vector4<UInt8>
}

struct GNDSurface {

    var height: Vector4<Float>
    var tile_up: Int32
    var tile_front: Int32
    var tile_right: Int32
}

class GNDDocument: Document<GNDDocument.Contents> {

    struct Contents {
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
    }

    override func load(from data: Data) throws -> Result<Contents, DocumentError> {
        let stream = DataStream(data: data)
        let reader = BinaryReader(stream: stream)

        do {
            let contents = try reader.readGNDContents()
            return .success(contents)
        } catch {
            return .failure(.invalidContents)
        }
    }
}

extension BinaryReader {

    fileprivate func readGNDContents() throws -> GNDDocument.Contents {
        let header = try readString(count: 4)
        guard header == "GRGN" else {
            throw DocumentError.invalidContents
        }

        let major = try readUInt8()
        let minor = try readUInt8()
        let version = "\(major).\(minor)"

        let width = try readUInt32()
        let height = try readUInt32()
        let zoom = try readFloat32()

        let (textures, textureIndexes) = try readGNDTextures()
        let lightmap = try readGNDLightmap()

        let tiles = try readGNDTiles(textures: textures, textureIndexes: textureIndexes)
        let surfaces = try readGNDSurfaces(width: width, height: height)

        let contents = GNDDocument.Contents(
            header: header,
            version: version,
            width: width,
            height: height,
            zoom: zoom,
            textures: textures,
            textureIndexes: textureIndexes,
            lightmap: lightmap,
            tiles: tiles,
            surfaces: surfaces
        )
        return contents
    }

    fileprivate func readGNDTextures() throws -> ([String], [UInt16]) {
        let count = try readUInt32()
        let length = try readUInt32()

        var indexes: [UInt16] = []
        var textures: [String] = []

        for _ in 0..<count {
            let texture = try readString(count: Int(length))
            var pos = textures.firstIndex(of: texture) ?? -1

            if pos == -1 {
                textures.append(texture)
                pos = textures.count - 1
            }

            indexes.append(UInt16(pos))
        }

        return (textures, indexes)
    }

    fileprivate func readGNDLightmap() throws -> GNDLightmap {
        let count = try readUInt32()
        let per_cell_x = try readInt32()
        let per_cell_y = try readInt32()
        let size_cell = try readInt32()
        let per_cell = per_cell_x * per_cell_y * size_cell

        let lightmap = try GNDLightmap(
            per_cell: per_cell,
            count: count,
            data: readData(count: Int(count) * Int(per_cell) * 4)
        )
        return lightmap
    }

    fileprivate func readGNDTiles(textures: [String], textureIndexes: [UInt16]) throws -> [GNDTile] {
        let count = try readUInt32()
        var tiles: [GNDTile] = []

        func ATLAS_GENERATE(tile: inout GNDTile) {
            let ATLAS_COLS         = roundf(sqrtf(Float(textures.count)))
            let ATLAS_ROWS         = ceilf(sqrtf(Float(textures.count)))
            let ATLAS_WIDTH        = powf(2, ceilf(logf(ATLAS_COLS * 258) / logf(2)))
            let ATLAS_HEIGHT       = powf(2, ceilf(logf(ATLAS_ROWS * 258) / logf(2)))
            let ATLAS_FACTOR_U     = (ATLAS_COLS * 258) / ATLAS_WIDTH
            let ATLAS_FACTOR_V     = (ATLAS_ROWS * 258) / ATLAS_HEIGHT
            let ATLAS_PX_U         = Float(1) / Float(258)
            let ATLAS_PX_V         = Float(1) / Float(258)

            let u   = Float(Int(tile.texture) % Int(ATLAS_COLS))
            let v   = floorf(Float(tile.texture) / ATLAS_COLS)
            tile.u1 = (u + tile.u1 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
            tile.u2 = (u + tile.u2 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
            tile.u3 = (u + tile.u3 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
            tile.u4 = (u + tile.u4 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
            tile.v1 = (v + tile.v1 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
            tile.v2 = (v + tile.v2 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
            tile.v3 = (v + tile.v3 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
            tile.v4 = (v + tile.v4 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
        }

        for _ in 0..<count {
            var tile = try GNDTile(
                u1: readFloat32(),
                u2: readFloat32(),
                u3: readFloat32(),
                u4: readFloat32(),
                v1: readFloat32(),
                v2: readFloat32(),
                v3: readFloat32(),
                v4: readFloat32(),
                texture: readUInt16(),
                light: readUInt16(),
                color: [readUInt8(), readUInt8(), readUInt8(), readUInt8()]
            )
            tile.texture = textureIndexes[Int(tile.texture)]
            ATLAS_GENERATE(tile: &tile)
            tiles.append(tile)
        }

        return tiles
    }

    fileprivate func readGNDSurfaces(width: UInt32, height: UInt32) throws -> [GNDSurface] {
        let count = width * height
        var surfaces: [GNDSurface] = []

        for _ in 0..<count {
            let surface = try GNDSurface(
                height: [readFloat32() / 5, readFloat32() / 5, readFloat32() / 5, readFloat32() / 5],
                tile_up: readInt32(),
                tile_front: readInt32(),
                tile_right: readInt32()
            )
            surfaces.append(surface)
        }

        return surfaces
    }
}
