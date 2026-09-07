//
//  GND.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2020/6/22.
//

import BinaryIO
import Foundation

public struct GND: FileFormat {
    public var header: String
    public var version: FileFormatVersion
    public var width: Int32
    public var height: Int32
    public var zoom: Float
    public var textures: [String] = []
    public var lightmap: GND.Lightmap
    public var surfaces: [GND.Surface] = []
    public var cubes: [GND.Cube] = []
    public var water: GND.Water?

    public init(from decoder: BinaryDecoder) throws {
        header = try decoder.decode(String.self, lengthOfBytes: 4, encoding: .ascii)
        guard header == "GRGN" else {
            throw FileFormatError.invalidHeader(header, expected: "GRGN")
        }

        let major = try decoder.decode(UInt8.self)
        let minor = try decoder.decode(UInt8.self)
        version = FileFormatVersion(major: major, minor: minor)

        width = try decoder.decode(Int32.self)
        height = try decoder.decode(Int32.self)
        zoom = try decoder.decode(Float.self)

        let textureCount = try decoder.decode(Int32.self)
        let textureNameLength = try decoder.decode(Int32.self)

        for _ in 0..<textureCount {
            let texture = try decoder.decode(String.self, lengthOfBytes: Int(textureNameLength), encoding: .isoLatin1)
            textures.append(texture)
        }

        lightmap = try decoder.decode(GND.Lightmap.self)

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

        if version >= "1.8" {
            water = try decoder.decode(GND.Water.self, configuration: version)
        }
    }
}

extension GND {
    public struct Lightmap: BinaryDecodable, Sendable {
        public struct LightmapPixel: BinaryDecodable, Sendable {
            public var red: UInt8
            public var green: UInt8
            public var blue: UInt8

            public init(from decoder: BinaryDecoder) throws {
                red = try decoder.decode(UInt8.self)
                green = try decoder.decode(UInt8.self)
                blue = try decoder.decode(UInt8.self)
            }
        }

        public var sliceCount: Int32
        public var sliceWidth: Int32
        public var sliceHeight: Int32
        public var pixelFormat: Int32
        public var shadowmapPixels: [UInt8] = []
        public var lightmapPixels: [LightmapPixel] = []

        public init(from decoder: BinaryDecoder) throws {
            sliceCount = try decoder.decode(Int32.self)
            sliceWidth = try decoder.decode(Int32.self)
            sliceHeight = try decoder.decode(Int32.self)

            // Usually 1.
            pixelFormat = try decoder.decode(Int32.self)

            let pixelsPerSlice = Int(sliceWidth * sliceHeight)

            for _ in 0..<sliceCount {
                let shadowmapPerSlice = try decoder.decode([UInt8].self, count: pixelsPerSlice)
                shadowmapPixels.append(contentsOf: shadowmapPerSlice)

                let lightmapPerSlice = try decoder.decode([LightmapPixel].self, count: pixelsPerSlice)
                lightmapPixels.append(contentsOf: lightmapPerSlice)
            }
        }

        /// Where the pixel at `x`, `y` of a slice sits in `shadowmapPixels` and `lightmapPixels`.
        public func pixelIndex(inSlice slice: Int, x: Int, y: Int) -> Int {
            let pixelsPerSlice = Int(sliceWidth * sliceHeight)
            return slice * pixelsPerSlice + x + y * Int(sliceWidth)
        }
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

            let blue = try decoder.decode(UInt8.self)
            let green = try decoder.decode(UInt8.self)
            let red = try decoder.decode(UInt8.self)
            let alpha = try decoder.decode(UInt8.self)
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

        public var lowestAltitude: Float {
            [bottomLeftAltitude, bottomRightAltitude, topLeftAltitude, topRightAltitude].max()!
        }

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

extension GND {
    public struct Water: BinaryDecodableWithConfiguration, Sendable {
        public struct Zone: BinaryDecodable, Sendable {
            public var level: Float
            public var type: Int32
            public var waveHeight: Float
            public var waveSpeed: Float
            public var wavePitch: Float
            public var animationSpeed: Int32

            public init(from decoder: BinaryDecoder) throws {
                level = try decoder.decode(Float.self)
                type = try decoder.decode(Int32.self)
                waveHeight = try decoder.decode(Float.self)
                waveSpeed = try decoder.decode(Float.self)
                wavePitch = try decoder.decode(Float.self)
                animationSpeed = try decoder.decode(Int32.self)
            }
        }

        public var level: Float
        public var type: Int32
        public var waveHeight: Float
        public var waveSpeed: Float
        public var wavePitch: Float
        public var animationSpeed: Int32
        public var splitWidth: Int32
        public var splitHeight: Int32
        public var zones: [GND.Water.Zone] = []

        public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
            level = try decoder.decode(Float.self)
            type = try decoder.decode(Int32.self)
            waveHeight = try decoder.decode(Float.self)
            waveSpeed = try decoder.decode(Float.self)
            wavePitch = try decoder.decode(Float.self)
            animationSpeed = try decoder.decode(Int32.self)
            splitWidth = try decoder.decode(Int32.self)
            splitHeight = try decoder.decode(Int32.self)

            if version >= "1.9" {
                let zoneCount = splitWidth * splitHeight
                for _ in 0..<zoneCount {
                    let zone = try decoder.decode(GND.Water.Zone.self)
                    zones.append(zone)
                }
            }
        }
    }
}
