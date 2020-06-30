//
//  STRDocument.swift
//  RagnarokOnlineWorld
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

class STRDocument: Document<Void> {

    private var reader: BinaryReader!

    private(set) var header = ""
    private(set) var version: UInt32 = 0
    private(set) var fps: UInt32 = 0
    private(set) var maxKey: UInt32 = 0
    private(set) var layernum: UInt32 = 0
    private(set) var layers: [STRLayer] = []

    override func load(from data: Data) throws -> Result<Void, DocumentError> {
        let stream = DataStream(data: data)
        reader = BinaryReader(stream: stream)

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

        layers = []
        for _ in 0..<layernum {
            let layer = try readLayer()
            layers.append(layer)
        }

        reader = nil

        return .success(())
    }

    private func readLayer() throws -> STRLayer {
        let texcnt = try reader.readInt32()

        var texname: [String] = []
        for _ in 0..<texcnt {
            let name = try "data\\texture\\effect\\" + reader.readString(count: 128)
            texname.append(name)
        }

        let anikeynum = try reader.readInt32()

        var animations: [STRAnimation] = []
        for _ in 0..<anikeynum {
            let animation = try readAnimation()
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

    private func readAnimation() throws -> STRAnimation {
        let animation = try STRAnimation(
            frame: reader.readInt32(),
            type: reader.readUInt32(),
            pos: [reader.readFloat32(), reader.readFloat32()],
            uv: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32()],
            xy: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32()],
            aniframe: reader.readFloat32(),
            anitype: reader.readUInt32(),
            delay: reader.readFloat32(),
            angle: reader.readFloat32() / (1024 / 360),
            color: [reader.readFloat32() / 255, reader.readFloat32() / 255, reader.readFloat32() / 255, reader.readFloat32() / 255],
            srcalpha: reader.readUInt32(),
            destalpha: reader.readUInt32(),
            mtpreset: reader.readUInt32()
        )
        return animation
    }
}
