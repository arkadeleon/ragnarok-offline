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

class RSWDocument: Document<RSWDocument.Contents> {

    struct Contents {
        var header: String
        var version: String
        var files: RSWFiles
        var water: RSWWater
        var light: RSWLight
        var ground: RSWGround
        var models: [RSWObject.Model]
        var lights: [RSWObject.Light]
        var sounds: [RSWObject.Sound]
        var effects: [RSWObject.Effect]
    }

    override func load(from data: Data) throws -> Result<Contents, DocumentError> {
        let stream = DataStream(data: data)
        let reader = BinaryReader(stream: stream)

        do {
            let contents = try reader.readRSWContents()
            return .success(contents)
        } catch {
            return .failure(.invalidContents)
        }
    }
}

extension BinaryReader {

    fileprivate func readRSWContents() throws -> RSWDocument.Contents {
        let header = try readString(count: 4)
        guard header == "GRSW" else {
            throw DocumentError.invalidContents
        }

        let major = try readUInt8()
        let minor = try readUInt8()
        let version = "\(major).\(minor)"

        var files = RSWFiles()
        files.ini = try readString(count: 40)
        files.gnd = try readString(count: 40)
        files.gat = try readString(count: 40)

        if version >= "1.4" {
            files.src = try readString(count: 40)
        }

        var water = RSWWater()
        if version >= "1.3" {
            water.level = try readFloat32() / 5

            if version >= "1.8" {
                water.type = try readInt32()
                water.waveHeight = try readFloat32() / 5
                water.waveSpeed = try readFloat32()
                water.wavePitch = try readFloat32()

                if version >= "1.9" {
                    water.animSpeed = try readInt32()
                }
            }
        }

        var light = RSWLight()
        if version >= "1.5" {
            light.longitude = try readInt32()
            light.latitude = try readInt32()
            light.diffuse = try [readFloat32(), readFloat32(), readFloat32()]
            light.ambient = try [readFloat32(), readFloat32(), readFloat32()]

            if version >= "1.7" {
                light.opacity = try readFloat32()
            }
        }

        var ground = RSWGround()
        if version >= "1.6" {
            ground.top = try readInt32()
            ground.bottom = try readInt32()
            ground.left = try readInt32()
            ground.right = try readInt32()
        }

        let count = try readInt32()

        var models: [RSWObject.Model] = []
        var lights: [RSWObject.Light] = []
        var sounds: [RSWObject.Sound] = []
        var effects: [RSWObject.Effect] = []

        for _ in 0..<count {
            switch (try readInt32()) {
            case 1:
                let model = try RSWObject.Model(
                    name: version >= "1.3" ? readString(count: 40) : "",
                    animType: version >= "1.3" ? readInt32() : 0,
                    animSpeed: version >= "1.3" ? readFloat32() : 0,
                    blockType: version >= "1.3" ? readInt32() : 0,
                    filename: readString(count: 80),
                    nodename:  readString(count: 80),
                    position: [readFloat32() / 5, readFloat32() / 5, readFloat32() / 5],
                    rotation: [readFloat32(), readFloat32(), readFloat32()],
                    scale: [readFloat32() / 5, readFloat32() / 5, readFloat32() / 5]
                )
                models.append(model)
            case 2:
                let light = try RSWObject.Light(
                    name: readString(count: 80),
                    pos: [readFloat32() / 5, readFloat32() / 5, readFloat32() / 5],
                    color: [readInt32(), readInt32(), readInt32()],
                    range: readFloat32()
                )
                lights.append(light)
            case 3:
                let sound = try RSWObject.Sound(
                    name: readString(count: 80),
                    file: readString(count: 80),
                    pos: [readFloat32() / 5, readFloat32() / 5, readFloat32() / 5],
                    vol: readFloat32(),
                    width: readInt32(),
                    height: readInt32(),
                    range: readFloat32(),
                    cycle: version >= "2.0" ? readFloat32() : 0
                )
                sounds.append(sound)
            case 4:
                let effect = try RSWObject.Effect(
                    name: readString(count: 80),
                    pos: [readFloat32() / 5, readFloat32() / 5, readFloat32() / 5],
                    id: readInt32(),
                    delay: readFloat32() * 10,
                    param: [readFloat32(), readFloat32(), readFloat32(), readFloat32()]
                )
                effects.append(effect)
            default:
                break
            }
        }

        let contents = RSWDocument.Contents(
            header: header,
            version: version,
            files: files,
            water: water,
            light: light,
            ground: ground,
            models: models,
            lights: lights,
            sounds: sounds,
            effects: effects
        )
        return contents
    }
}
