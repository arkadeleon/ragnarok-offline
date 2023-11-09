//
//  STRDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/19.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

struct STRLayer {

    var texcnt: Int32
    var texname: [String]
    var anikeynum: Int32
    var animations: [STRAnimation]

    init(from reader: BinaryReader) throws {
        texcnt = try reader.readInt()
        texname = []
        for _ in 0..<texcnt {
            let name = try "data\\texture\\effect\\" + reader.readString(128)
            texname.append(name)
        }

        anikeynum = try reader.readInt()
        animations = []
        for _ in 0..<anikeynum {
            let animation = try STRAnimation(from: reader)
            animations.append(animation)
        }
    }
}

struct STRAnimation {

    var frame: Int32
    var type: UInt32
    var pos: simd_float2
    var uv: [Float]
    var xy: [Float]
    var aniframe: Float
    var anitype: UInt32
    var delay: Float
    var angle: Float
    var color: simd_float4
    var srcalpha: UInt32
    var destalpha: UInt32
    var mtpreset: UInt32

    init(from reader: BinaryReader) throws {
        frame = try reader.readInt()
        type = try reader.readInt()
        pos = try [
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
        aniframe = try reader.readFloat()
        anitype = try reader.readInt()
        delay = try reader.readFloat()
        angle = try reader.readFloat() / (1024 / 360)
        color = try [
            reader.readFloat() / 255,
            reader.readFloat() / 255,
            reader.readFloat() / 255,
            reader.readFloat() / 255
        ]
        srcalpha = try reader.readInt()
        destalpha = try reader.readInt()
        mtpreset = try reader.readInt()
    }
}

struct STRDocument {

    var header: String
    var version: UInt32
    var fps: UInt32
    var maxKey: UInt32
    var layernum: UInt32
    var layers: [STRLayer]

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

        version = try reader.readInt()
        guard version == 0x94 else {
            throw DocumentError.invalidContents
        }

        fps = try reader.readInt()
        maxKey = try reader.readInt()
        layernum = try reader.readInt()

        _ = try reader.readBytes(16)

        layers = []
        for _ in 0..<layernum {
            let layer = try STRLayer(from: reader)
            layers.append(layer)
        }
    }
}
