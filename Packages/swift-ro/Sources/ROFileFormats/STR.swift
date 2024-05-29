//
//  STR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/19.
//

import Foundation
import ROCore

public struct STR: Encodable {
    public var header: String
    public var version: String
    public var fps: Int32
    public var maxKeyframeIndex: Int32
    public var layers: [Layer] = []

    public init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(4)
        guard header == "STRM" else {
            throw FileFormatError.invalidHeader(header, expected: "STRM")
        }

        let major: UInt8 = try reader.readInt()
        let minor: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        _ = try reader.readBytes(2)

        fps = try reader.readInt()
        maxKeyframeIndex = try reader.readInt()

        let layerCount: Int32 = try reader.readInt()

        _ = try reader.readBytes(16)

        for _ in 0..<layerCount {
            let layer = try Layer(from: reader)
            layers.append(layer)
        }
    }
}

extension STR {
    public struct Layer: Encodable {
        public var textures: [String] = []
        public var keyframes: [Keyframe] = []

        init(from reader: BinaryReader) throws {
            let textureCount: Int32 = try reader.readInt()
            for _ in 0..<textureCount {
                let texture = try reader.readString(128)
                textures.append(texture)
            }

            let keyframeCount: Int32 = try reader.readInt()
            for _ in 0..<keyframeCount {
                let keyframe = try Keyframe(from: reader)
                keyframes.append(keyframe)
            }
        }
    }
}

extension STR {
    public struct Keyframe: Encodable {
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

        init(from reader: BinaryReader) throws {
            frameIndex = try reader.readInt()
            type = try reader.readInt()
            position = try [
                reader.readFloat(),
                reader.readFloat()
            ]
            uv = try [
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat()
            ]
            xy = try [
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat()
            ]
            textureIndex = try reader.readFloat()
            animationType = try reader.readInt()
            delay = try reader.readFloat()
            angle = try reader.readFloat() / (1024 / 360)
            color = try [
                reader.readFloat() / 255,
                reader.readFloat() / 255,
                reader.readFloat() / 255,
                reader.readFloat() / 255
            ]
            sourceAlpha = try reader.readInt()
            destinationAlpha = try reader.readInt()
            multiTexturePreset = try reader.readInt()
        }
    }
}
