//
//  STR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/19.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import simd

struct STR {
    var header: String
    var version: String
    var fps: Int32
    var maxKeyframeIndex: Int32
    var layers: [Layer] = []

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(4)
        guard header == "STRM" else {
            throw DocumentError.invalidContents
        }

        let minor: UInt8 = try reader.readInt()
        let major: UInt8 = try reader.readInt()
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
    struct Layer {
        var textureNames: [String] = []
        var keyframes: [Keyframe] = []

        init(from reader: BinaryReader) throws {
            let textureCount: Int32 = try reader.readInt()
            for _ in 0..<textureCount {
                let textureName = try reader.readString(128)
                textureNames.append(textureName)
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
    struct Keyframe {
        var frameIndex: Int32
        var type: Int32
        var position: simd_float2
        var uv: simd_float8
        var xy: simd_float8
        var textureIndex: Float
        var animationType: Int32
        var delay: Float
        var angle: Float
        var color: simd_float4
        var sourceAlpha: Int32
        var destinationAlpha: Int32
        var multiTexturePreset: Int32

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
