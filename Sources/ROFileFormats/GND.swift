//
//  GND.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import ROStream

public struct GND: Encodable {
    public var header: String
    public var version: String
    public var width: Int32
    public var height: Int32
    public var zoom: Float

    public var textures: [String] = []

    public var lightmap: GNDLightmap

    public var surfaces: [Surface] = []

    public var cubes: [Cube] = []

    public init(data: Data) throws {
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

        let textureCount: UInt32 = try reader.readInt()
        let textureNameLength: UInt32 = try reader.readInt()

        for _ in 0..<textureCount {
            let texture = try reader.readString(Int(textureNameLength), encoding: .koreanEUC)
            textures.append(texture)
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

        let surfaceCount: UInt32 = try reader.readInt()
        for _ in 0..<surfaceCount {
            let surface = try Surface(from: reader)
            surfaces.append(surface)
        }

        let cubeCount = width * height
        for _ in 0..<cubeCount {
            let cube = try Cube(from: reader)
            cubes.append(cube)
        }
    }
}

extension GND {
    public struct GNDLightmap: Encodable {
        public var per_cell: Int32
        public var count: UInt32
        public var data: [UInt8]
    }
}

extension GND {
    public struct Surface: Encodable {
        public var u1: Float
        public var u2: Float
        public var u3: Float
        public var u4: Float
        public var v1: Float
        public var v2: Float
        public var v3: Float
        public var v4: Float
        public var textureIndex: Int16
        public var lightmapIndex: UInt16
        public var color: RGBAColor

        init(from reader: BinaryReader) throws {
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
            color = RGBAColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}

extension GND {
    public struct Cube: Encodable {
        public var bottomLeft: Float
        public var bottomRight: Float
        public var topLeft: Float
        public var topRight: Float

        public var topSurface: Int32
        public var frontSurface: Int32
        public var rightSurface: Int32

        init(from reader: BinaryReader) throws {
            bottomLeft = try reader.readFloat()
            bottomRight = try reader.readFloat()
            topLeft = try reader.readFloat()
            topRight = try reader.readFloat()

            topSurface = try reader.readInt()
            frontSurface = try reader.readInt()
            rightSurface = try reader.readInt()
        }
    }
}
