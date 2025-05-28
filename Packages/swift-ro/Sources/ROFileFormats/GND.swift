//
//  GND.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/22.
//

import BinaryIO
import Foundation

public struct GND: BinaryDecodable, Sendable {
    public var header: String
    public var version: String
    public var width: Int32
    public var height: Int32
    public var zoom: Float

    public var textures: [String] = []

    public var lightmap: GND.Lightmap

    public var surfaces: [GND.Surface] = []

    public var cubes: [GND.Cube] = []

    public init(data: Data) throws {
        let decoder = BinaryDecoder(data: data)
        self = try decoder.decode(GND.self)
    }

    public init(from decoder: BinaryDecoder) throws {
        header = try decoder.decode(String.self, lengthOfBytes: 4)
        guard header == "GRGN" else {
            throw FileFormatError.invalidHeader(header, expected: "GRGN")
        }

        let major = try decoder.decode(UInt8.self)
        let minor = try decoder.decode(UInt8.self)
        version = "\(major).\(minor)"

        width = try decoder.decode(Int32.self)
        height = try decoder.decode(Int32.self)
        zoom = try decoder.decode(Float.self)

        let textureCount = try decoder.decode(Int32.self)
        let textureNameLength = try decoder.decode(Int32.self)

        for _ in 0..<textureCount {
            let texture = try decoder.decode(String.self, lengthOfBytes: Int(textureNameLength), encoding: .koreanEUC)
            textures.append(texture)
        }

        let count = try decoder.decode(Int32.self)
        let per_cell_x = try decoder.decode(Int32.self)
        let per_cell_y = try decoder.decode(Int32.self)
        let size_cell = try decoder.decode(Int32.self)
        let per_cell = per_cell_x * per_cell_y * size_cell

        lightmap = try GND.Lightmap(
            per_cell: per_cell,
            count: count,
            data: decoder.decode([UInt8].self, count: Int(count) * Int(per_cell) * 4)
        )

        let surfaceCount = try decoder.decode(Int32.self)
        for _ in 0..<surfaceCount {
            let surface = try decoder.decode(GND.Surface.self)
            surfaces.append(surface)
        }

        let cubeCount = width * height
        for _ in 0..<cubeCount {
            let cube = try decoder.decode(GND.Cube.self)
            cubes.append(cube)
        }
    }
}

extension GND {
    public struct Lightmap: Sendable {
        public var per_cell: Int32
        public var count: Int32
        public var data: [UInt8]
    }
}

extension GND {
    public struct Surface: BinaryDecodable, Sendable {
        public var u: SIMD4<Float>
        public var v: SIMD4<Float>
        public var textureIndex: Int16
        public var lightmapIndex: Int16
        public var color: RGBAColor

        public init(from decoder: BinaryDecoder) throws {
            u = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            v = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]

            textureIndex = try decoder.decode(Int16.self)
            lightmapIndex = try decoder.decode(Int16.self)

            let alpha = try decoder.decode(UInt8.self)
            let red = try decoder.decode(UInt8.self)
            let green = try decoder.decode(UInt8.self)
            let blue = try decoder.decode(UInt8.self)
            color = RGBAColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}

extension GND {
    public struct Cube: BinaryDecodable, Sendable {
        public var bottomLeftAltitude: Float
        public var bottomRightAltitude: Float
        public var topLeftAltitude: Float
        public var topRightAltitude: Float

        public var topSurfaceIndex: Int32
        public var frontSurfaceIndex: Int32
        public var rightSurfaceIndex: Int32

        public init(from decoder: BinaryDecoder) throws {
            bottomLeftAltitude = try decoder.decode(Float.self)
            bottomRightAltitude = try decoder.decode(Float.self)
            topLeftAltitude = try decoder.decode(Float.self)
            topRightAltitude = try decoder.decode(Float.self)

            topSurfaceIndex = try decoder.decode(Int32.self)
            frontSurfaceIndex = try decoder.decode(Int32.self)
            rightSurfaceIndex = try decoder.decode(Int32.self)
        }
    }
}

extension GND.Cube {
    public var lowestAltitude: Float {
        [bottomLeftAltitude, bottomRightAltitude, topLeftAltitude, topRightAltitude].min()!
    }
}
