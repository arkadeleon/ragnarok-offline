//
//  RSWDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/19.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import SGLMath

struct RSWFiles {

    var ini = ""
    var gnd = ""
    var gat = ""
    var src = ""
}

struct RSWWater {

    var level: Float = 0
    var type: Int32 = 0
    var waveHeight: Float = 0.2
    var waveSpeed: Float = 2
    var wavePitch: Float = 50
    var animSpeed: Int32 = 3
    var images: [String] = []
}

struct RSWLight {

    var longitude: Int32 = 45
    var latitude: Int32 = 45
    var diffuse: Vector3<Float> = [1, 1, 1]
    var ambient: Vector3<Float> = [0.3, 0.3, 0.3]
    var opacity: Float = 1
    var direction: Vector3<Float> = [0, 0, 0]
}

struct RSWGround {

    var top: Int32 = -500
    var bottom: Int32 = 500
    var left: Int32 = -500
    var right: Int32 = 500
}

enum RSWObject {

    struct Model {

        var name: String
        var animType: Int32
        var animSpeed: Float
        var blockType: Int32
        var filename: String
        var nodename: String
        var position: Vector3<Float>
        var rotation: Vector3<Float>
        var scale: Vector3<Float>
    }

    struct Light {

        var name: String
        var pos: Vector3<Float>
        var color: Vector3<Int32>
        var range: Float
    }

    struct Sound {

        var name: String
        var file: String
        var pos: Vector3<Float>
        var vol: Float
        var width: Int32
        var height: Int32
        var range: Float
        var cycle: Float
    }

    struct Effect {

        var name: String
        var pos: Vector3<Float>
        var id: Int32
        var delay: Float
        var param: Vector4<Float>
    }
}

class RSWDocument: Document {

    private(set) var header = ""
    private(set) var version = ""
    private(set) var files = RSWFiles()
    private(set) var water = RSWWater()
    private(set) var light = RSWLight()
    private(set) var ground = RSWGround()
    private(set) var models: [RSWObject.Model] = []
    private(set) var lights: [RSWObject.Light] = []
    private(set) var sounds: [RSWObject.Sound] = []
    private(set) var effects: [RSWObject.Effect] = []

    override func load(from contents: Data) throws {
        let stream = DataStream(data: contents)
        let reader = BinaryReader(stream: stream)

        header = try reader.readString(count: 4)
        guard header == "GRSW" else {
            throw StreamError.invalidContents
        }

        let major = try String(reader.readUInt8())
        let minor = try String(reader.readUInt8())
        version = major + "." + minor

        files.ini = try reader.readString(count: 40)
        files.gnd = try reader.readString(count: 40)
        files.gat = try reader.readString(count: 40)

        if version >= "1.4" {
            files.src = try reader.readString(count: 40)
        }

        if version >= "1.3" {
            water.level = try reader.readFloat32() / 5

            if version >= "1.8" {
                water.type = try reader.readInt32()
                water.waveHeight = try reader.readFloat32() / 5
                water.waveSpeed = try reader.readFloat32()
                water.wavePitch = try reader.readFloat32()

                if version >= "1.9" {
                    water.animSpeed = try reader.readInt32()
                }
            }
        }

        if version >= "1.5" {
            light.longitude = try reader.readInt32()
            light.latitude = try reader.readInt32()
            light.diffuse = try [reader.readFloat32(), reader.readFloat32(), reader.readFloat32()]
            light.ambient = try [reader.readFloat32(), reader.readFloat32(), reader.readFloat32()]

            if version >= "1.7" {
                light.opacity = try reader.readFloat32()
            }
        }

        if version >= "1.6" {
            ground.top = try reader.readInt32()
            ground.bottom = try reader.readInt32()
            ground.left = try reader.readInt32()
            ground.right = try reader.readInt32()
        }

        let count = try reader.readInt32()

        for _ in 0..<count {
            switch (try reader.readInt32()) {
            case 1:
                let model = try RSWObject.Model(
                    name: version >= "1.3" ? reader.readString(count: 40) : "",
                    animType: version >= "1.3" ? reader.readInt32() : 0,
                    animSpeed: version >= "1.3" ? reader.readFloat32() : 0,
                    blockType: version >= "1.3" ? reader.readInt32() : 0,
                    filename: reader.readString(count: 80),
                    nodename:  reader.readString(count: 80),
                    position: [reader.readFloat32() / 5, reader.readFloat32() / 5, reader.readFloat32() / 5],
                    rotation: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32()],
                    scale: [reader.readFloat32() / 5, reader.readFloat32() / 5, reader.readFloat32() / 5]
                )
                models.append(model)
            case 2:
                let light = try RSWObject.Light(
                    name: reader.readString(count: 80),
                    pos: [reader.readFloat32() / 5, reader.readFloat32() / 5, reader.readFloat32() / 5],
                    color: [reader.readInt32(), reader.readInt32(), reader.readInt32()],
                    range: reader.readFloat32()
                )
                lights.append(light)
            case 3:
                let sound = try RSWObject.Sound(
                    name: reader.readString(count: 80),
                    file: reader.readString(count: 80),
                    pos: [reader.readFloat32() / 5, reader.readFloat32() / 5, reader.readFloat32() / 5],
                    vol: reader.readFloat32(),
                    width: reader.readInt32(),
                    height: reader.readInt32(),
                    range: reader.readFloat32(),
                    cycle: version >= "2.0" ? reader.readFloat32() : 0
                )
                sounds.append(sound)
            case 4:
                let effect = try RSWObject.Effect(
                    name: reader.readString(count: 80),
                    pos: [reader.readFloat32() / 5, reader.readFloat32() / 5, reader.readFloat32() / 5],
                    id: reader.readInt32(),
                    delay: reader.readFloat32() * 10,
                    param: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32()]
                )
                effects.append(effect)
            default:
                break
            }
        }
    }
}
