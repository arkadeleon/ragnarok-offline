//
//  ACTDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import SGLMath

struct ACTLayer {

    var pos: Vector2<Int32>
    var index: Int32
    var is_mirror: Int32
    var scale: Vector2<Float>
    var color: Vector4<Float>
    var angle: Int32
    var spr_type: Int32
    var width: Int32
    var height: Int32
}

struct ACTAnimation {

    var layers: [ACTLayer]
    var sound: Int32
    var pos: [Vector2<Int32>]
}

struct ACTAction {

    var animations: [ACTAnimation]
    var delay: Float
}

class ACTDocument: Document {

    private var reader: BinaryReader!

    private(set) var header = ""
    private(set) var version = ""
    private(set) var actions: [ACTAction] = []
    private(set) var sounds: [String] = []

    override func load(from contents: Data) throws {
        let stream = DataStream(data: contents)
        reader = BinaryReader(stream: stream)

        header = try reader.readString(count: 2)
        guard header == "AC" else {
            throw DocumentError.invalidContents
        }

        let minor = try reader.readUInt8()
        let major = try reader.readUInt8()
        version = "\(major).\(minor)"

        let actionCount = try reader.readUInt16()

        try reader.skip(count: 10)

        actions = []
        for _ in 0..<actionCount {
            let action = try readAction()
            actions.append(action)
        }

        if version >= "2.1" {
            let soundCount = try reader.readInt32()
            sounds = []
            for _ in 0..<soundCount {
                let sound = try reader.readString(count: 40)
                sounds.append(sound)
            }

            if version >= "2.2" {
                for i in 0..<Int(actionCount) {
                    actions[i].delay = try reader.readFloat32() * 25
                }
            }
        }

        reader = nil
    }

    private func readAction() throws -> ACTAction {
        let animationCount = try reader.readUInt32()
        var animations: [ACTAnimation] = []
        for _ in 0..<animationCount {
            try reader.skip(count: 32)
            let animation = try readAnimation()
            animations.append(animation)
        }

        return ACTAction(
            animations: animations,
            delay: 150
        )
    }

    private func readAnimation() throws -> ACTAnimation {
        let layerCount = try reader.readUInt32()
        var layers: [ACTLayer] = []
        for _ in 0..<layerCount {
            let layer = try readLayer()
            layers.append(layer)
        }

        let sound = try version >= "2.0" ? reader.readInt32() : -1

        var positions: [Vector2<Int32>] = []
        if version >= "2.3" {
            let positionCount = try reader.readInt32()
            for _ in 0..<positionCount {
                try reader.skip(count: 4)
                let position: Vector2<Int32> = try [reader.readInt32(), reader.readInt32()]
                positions.append(position)
                try reader.skip(count: 4)
            }
        }

        return ACTAnimation(
            layers: layers,
            sound: sound,
            pos: positions
        )
    }

    private func readLayer() throws -> ACTLayer {
        var layer = try ACTLayer(
            pos: [reader.readInt32(), reader.readInt32()],
            index: reader.readInt32(),
            is_mirror: reader.readInt32(),
            scale: [1.0, 1.0],
            color: [1.0, 1.0, 1.0, 1.0],
            angle: 0,
            spr_type: 0,
            width: 0,
            height: 0
        )

        if version >= "2.0" {
            layer.color[0] = try Float(reader.readUInt8()) / 255
            layer.color[1] = try Float(reader.readUInt8()) / 255
            layer.color[2] = try Float(reader.readUInt8()) / 255
            layer.color[3] = try Float(reader.readUInt8()) / 255
            layer.scale[0] = try reader.readFloat32()
            layer.scale[1] = try version <= "2.3" ? layer.scale[0] : reader.readFloat32()
            layer.angle = try reader.readInt32()
            layer.spr_type = try reader.readInt32()

            if version >= "2.5" {
                layer.width = try reader.readInt32()
                layer.height = try reader.readInt32()
            }
        }

        return layer
    }
}
