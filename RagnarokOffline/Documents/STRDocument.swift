//
//  STRDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/19.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import SGLMath

struct STRLayer {

    var texcnt: Int32
    var texname: [String]
    var anikeynum: Int32
    var animations: [STRAnimation]
}

struct STRAnimation {

    var frame: Int32
    var type: UInt32
    var pos: Vector2<Float>
    var uv: [Float]
    var xy: [Float]
    var aniframe: Float
    var anitype: UInt32
    var delay: Float
    var angle: Float
    var color: Vector4<Float>
    var srcalpha: UInt32
    var destalpha: UInt32
    var mtpreset: UInt32
}

struct STRDocument: Document {

    var header: String
    var version: UInt32
    var fps: UInt32
    var maxKey: UInt32
    var layernum: UInt32
    var layers: [STRLayer]

    init(from stream: Stream) throws {
        let reader = StreamReader(stream: stream)

        header = try reader.readString(count: 4)
        guard header == "STRM" else {
            throw DocumentError.invalidContents
        }

        version = try reader.readUInt32()
        guard version == 0x94 else {
            throw DocumentError.invalidContents
        }

        fps = try reader.readUInt32()
        maxKey = try reader.readUInt32()
        layernum = try reader.readUInt32()

        try reader.skip(count: 16)

        var layers: [STRLayer] = []
        for _ in 0..<layernum {
            let layer = try reader.readSTRLayer()
            layers.append(layer)
        }
        self.layers = layers
    }
}

extension StreamReader {

    fileprivate func readSTRLayer() throws -> STRLayer {
        let texcnt = try readInt32()
        var texname: [String] = []
        for _ in 0..<texcnt {
            let name = try "data\\texture\\effect\\" + readString(count: 128)
            texname.append(name)
        }

        let anikeynum = try readInt32()
        var animations: [STRAnimation] = []
        for _ in 0..<anikeynum {
            let animation = try readSTRAnimation()
            animations.append(animation)
        }

        let layer = STRLayer(
            texcnt: texcnt,
            texname: texname,
            anikeynum: anikeynum,
            animations: animations
        )
        return layer
    }

    fileprivate func readSTRAnimation() throws -> STRAnimation {
        let animation = try STRAnimation(
            frame: readInt32(),
            type: readUInt32(),
            pos: [readFloat32(), readFloat32()],
            uv: [readFloat32(), readFloat32(), readFloat32(), readFloat32(), readFloat32(), readFloat32(), readFloat32(), readFloat32()],
            xy: [readFloat32(), readFloat32(), readFloat32(), readFloat32(), readFloat32(), readFloat32(), readFloat32(), readFloat32()],
            aniframe: readFloat32(),
            anitype: readUInt32(),
            delay: readFloat32(),
            angle: readFloat32() / (1024 / 360),
            color: [readFloat32() / 255, readFloat32() / 255, readFloat32() / 255, readFloat32() / 255],
            srcalpha: readUInt32(),
            destalpha: readUInt32(),
            mtpreset: readUInt32()
        )
        return animation
    }
}
