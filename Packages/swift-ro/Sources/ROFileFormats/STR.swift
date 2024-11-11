//
//  STR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/19.
//

import Foundation
import ROCore

public struct STR: BinaryDecodable {
    public var header: String
    public var version: String
    public var fps: Int32
    public var maxKeyframeIndex: Int32
    public var layers: [Layer] = []

    public init(data: Data) throws {
        let decoder = BinaryDecoder(data: data)
        self = try decoder.decode(STR.self)
    }

    public init(from decoder: BinaryDecoder) throws {
        header = try decoder.decode(String.self, lengthOfBytes: 4)
        guard header == "STRM" else {
            throw FileFormatError.invalidHeader(header, expected: "STRM")
        }

        let major = try decoder.decode(UInt8.self)
        let minor = try decoder.decode(UInt8.self)
        version = "\(major).\(minor)"

        _ = try decoder.decode([UInt8].self, count: 2)

        fps = try decoder.decode(Int32.self)
        maxKeyframeIndex = try decoder.decode(Int32.self)

        let layerCount = try decoder.decode(Int32.self)

        _ = try decoder.decode([UInt8].self, count: 16)

        for _ in 0..<layerCount {
            let layer = try decoder.decode(Layer.self)
            layers.append(layer)
        }
    }
}

extension STR {
    public struct Layer: BinaryDecodable {
        public var textures: [String] = []
        public var keyframes: [Keyframe] = []

        public init(from decoder: BinaryDecoder) throws {
            let textureCount = try decoder.decode(Int32.self)
            for _ in 0..<textureCount {
                let texture = try decoder.decode(String.self, lengthOfBytes: 128)
                textures.append(texture)
            }

            let keyframeCount = try decoder.decode(Int32.self)
            for _ in 0..<keyframeCount {
                let keyframe = try decoder.decode(Keyframe.self)
                keyframes.append(keyframe)
            }
        }
    }
}

extension STR {
    public struct Keyframe: BinaryDecodable {
        public var frameIndex: Int32
        public var type: Int32
        public var position: SIMD2<Float>
        public var uv: SIMD8<Float>
        public var xy: SIMD8<Float>
        public var textureIndex: Float
        public var animationType: Int32
        public var delay: Float
        public var angle: Float
        public var color: SIMD4<Float>
        public var sourceAlpha: Int32
        public var destinationAlpha: Int32
        public var multiTexturePreset: Int32

        public init(from decoder: BinaryDecoder) throws {
            frameIndex = try decoder.decode(Int32.self)
            type = try decoder.decode(Int32.self)
            position = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            uv = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            xy = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            textureIndex = try decoder.decode(Float.self)
            animationType = try decoder.decode(Int32.self)
            delay = try decoder.decode(Float.self)
            angle = try decoder.decode(Float.self) / (1024 / 360)
            color = try [
                decoder.decode(Float.self) / 255,
                decoder.decode(Float.self) / 255,
                decoder.decode(Float.self) / 255,
                decoder.decode(Float.self) / 255,
            ]
            sourceAlpha = try decoder.decode(Int32.self)
            destinationAlpha = try decoder.decode(Int32.self)
            multiTexturePreset = try decoder.decode(Int32.self)
        }
    }
}
