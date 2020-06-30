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

class ACTDocument: Document<ACTDocument.Contents> {

    struct Contents {
        var header: String
        var version: String
        var actions: [ACTAction]
        var sounds: [String]
    }

    override func load(from data: Data) throws -> Result<Contents, DocumentError> {
        let stream = DataStream(data: data)
        let reader = BinaryReader(stream: stream)

        do {
            let contents = try reader.readACTContents()
            return .success(contents)
        } catch {
            return .failure(.invalidContents)
        }
    }
}

extension BinaryReader {

    fileprivate func readACTContents() throws -> ACTDocument.Contents {
        let header = try readString(count: 2)
        guard header == "AC" else {
            throw DocumentError.invalidContents
        }

        let minor = try readUInt8()
        let major = try readUInt8()
        let version = "\(major).\(minor)"

        let actionCount = try readUInt16()

        try skip(count: 10)

        var actions: [ACTAction] = []
        for _ in 0..<actionCount {
            let action = try readACTAction(version: version)
            actions.append(action)
        }

        var sounds: [String] = []
        if version >= "2.1" {
            let soundCount = try readInt32()
            for _ in 0..<soundCount {
                let sound = try readString(count: 40)
                sounds.append(sound)
            }

            if version >= "2.2" {
                for i in 0..<Int(actionCount) {
                    actions[i].delay = try readFloat32() * 25
                }
            }
        }

        let contents = ACTDocument.Contents(
            header: header,
            version: version,
            actions: actions,
            sounds: sounds
        )
        return contents
    }

    fileprivate func readACTAction(version: String) throws -> ACTAction {
        let animationCount = try readUInt32()
        var animations: [ACTAnimation] = []
        for _ in 0..<animationCount {
            try skip(count: 32)
            let animation = try readACTAnimation(version: version)
            animations.append(animation)
        }

        return ACTAction(
            animations: animations,
            delay: 150
        )
    }

    fileprivate func readACTAnimation(version: String) throws -> ACTAnimation {
        let layerCount = try readUInt32()
        var layers: [ACTLayer] = []
        for _ in 0..<layerCount {
            let layer = try readACTLayer(version: version)
            layers.append(layer)
        }

        let sound = try version >= "2.0" ? readInt32() : -1

        var positions: [Vector2<Int32>] = []
        if version >= "2.3" {
            let positionCount = try readInt32()
            for _ in 0..<positionCount {
                try skip(count: 4)
                let position: Vector2<Int32> = try [readInt32(), readInt32()]
                positions.append(position)
                try skip(count: 4)
            }
        }

        return ACTAnimation(
            layers: layers,
            sound: sound,
            pos: positions
        )
    }

    fileprivate func readACTLayer(version: String) throws -> ACTLayer {
        var layer = try ACTLayer(
            pos: [readInt32(), readInt32()],
            index: readInt32(),
            is_mirror: readInt32(),
            scale: [1.0, 1.0],
            color: [1.0, 1.0, 1.0, 1.0],
            angle: 0,
            spr_type: 0,
            width: 0,
            height: 0
        )

        if version >= "2.0" {
            layer.color[0] = try Float(readUInt8()) / 255
            layer.color[1] = try Float(readUInt8()) / 255
            layer.color[2] = try Float(readUInt8()) / 255
            layer.color[3] = try Float(readUInt8()) / 255
            layer.scale[0] = try readFloat32()
            layer.scale[1] = try version <= "2.3" ? layer.scale[0] : readFloat32()
            layer.angle = try readInt32()
            layer.spr_type = try readInt32()

            if version >= "2.5" {
                layer.width = try readInt32()
                layer.height = try readInt32()
            }
        }

        return layer
    }
}
