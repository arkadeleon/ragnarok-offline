//
//  GND.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/22.
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
            throw FileFormatError.invalidHeader(header, expected: "GRGN")
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
        public var u: SIMD4<Float>
        public var v: SIMD4<Float>
        public var textureIndex: Int16
        public var lightmapIndex: Int16
        public var color: Color

        init(from reader: BinaryReader) throws {
            u = try [
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat()
            ]
            v = try [
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat()
            ]

            textureIndex = try reader.readInt()
            lightmapIndex = try reader.readInt()

            let alpha: UInt8 = try reader.readInt()
            let red: UInt8 = try reader.readInt()
            let green: UInt8 = try reader.readInt()
            let blue: UInt8 = try reader.readInt()
            color = Color(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}

extension GND {
    public struct Cube: Encodable {
        public var bottomLeftAltitude: Float
        public var bottomRightAltitude: Float
        public var topLeftAltitude: Float
        public var topRightAltitude: Float

        public var topSurfaceIndex: Int32
        public var frontSurfaceIndex: Int32
        public var rightSurfaceIndex: Int32

        init(from reader: BinaryReader) throws {
            bottomLeftAltitude = try reader.readFloat()
            bottomRightAltitude = try reader.readFloat()
            topLeftAltitude = try reader.readFloat()
            topRightAltitude = try reader.readFloat()

            topSurfaceIndex = try reader.readInt()
            frontSurfaceIndex = try reader.readInt()
            rightSurfaceIndex = try reader.readInt()
        }
    }
}

extension GND.Cube {
    public var lowestAltitude: Float {
        [bottomLeftAltitude, bottomRightAltitude, topLeftAltitude, topRightAltitude].min()!
    }
}
