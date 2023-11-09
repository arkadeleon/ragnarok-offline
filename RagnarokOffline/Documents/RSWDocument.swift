//
//  RSWDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/19.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

struct RSWFiles {

    var ini: String
    var gnd: String
    var gat: String
    var src: String

    init(from reader: BinaryReader, version: String) throws {
        ini = try reader.readString(40, encoding: .ascii)

        gnd = try reader.readString(40, encoding: .ascii)

        gat = try reader.readString(40, encoding: .ascii)

        if version >= "1.4" {
            src = try reader.readString(40, encoding: .ascii)
        } else {
            src = ""
        }
    }
}

struct RSWWater {

    var level: Float = 0
    var type: Int32 = 0
    var waveHeight: Float = 0.2
    var waveSpeed: Float = 2
    var wavePitch: Float = 50
    var animSpeed: Int32 = 3
    var images: [String] = []

    init(from reader: BinaryReader, version: String) throws {
        if version >= "1.3" {
            level = try reader.readFloat() / 5

            if version >= "1.8" {
                type = try reader.readInt()
                waveHeight = try reader.readFloat() / 5
                waveSpeed = try reader.readFloat()
                wavePitch = try reader.readFloat()

                if version >= "1.9" {
                    animSpeed = try reader.readInt()
                }
            }
        }
    }
}

struct RSWLight {

    var longitude: Int32 = 45
    var latitude: Int32 = 45
    var diffuse: simd_float3 = [1, 1, 1]
    var ambient: simd_float3 = [0.3, 0.3, 0.3]
    var opacity: Float = 1
    var direction: simd_float3 = [0, 0, 0]

    init(from reader: BinaryReader, version: String) throws {
        if version >= "1.5" {
            longitude = try reader.readInt()
            latitude = try reader.readInt()
            diffuse = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
            ambient = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]

            if version >= "1.7" {
                opacity = try reader.readFloat()
            }
        }
    }
}

struct RSWGround {

    var top: Int32 = -500
    var bottom: Int32 = 500
    var left: Int32 = -500
    var right: Int32 = 500

    init(from reader: BinaryReader, version: String) throws {
        if version >= "1.6" {
            top = try reader.readInt()
            bottom = try reader.readInt()
            left = try reader.readInt()
            right = try reader.readInt()
        }
    }
}

enum RSWObject {

    struct Model {

        var name: String
        var animType: Int32
        var animSpeed: Float
        var blockType: Int32
        var filename: String
        var nodename: String
        var position: simd_float3
        var rotation: simd_float3
        var scale: simd_float3

        init(from reader: BinaryReader, version: String) throws {
            name = try version >= "1.3" ? reader.readString(40, encoding: .koreanEUC) : ""
            animType = try version >= "1.3" ? reader.readInt() : 0
            animSpeed = try version >= "1.3" ? reader.readFloat() : 0
            blockType = try version >= "1.3" ? reader.readInt() : 0
            filename = try reader.readString(80, encoding: .koreanEUC)
            nodename = try  reader.readString(80, encoding: .ascii)
            position = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
            rotation = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
            scale = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
        }
    }

    struct Light {

        var name: String
        var pos: simd_float3
        var color: simd_int3
        var range: Float

        init(from reader: BinaryReader, version: String) throws {
            name = try reader.readString(80, encoding: .ascii)
            pos = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
            color = try [reader.readInt(), reader.readInt(), reader.readInt()]
            range = try reader.readFloat()
        }
    }

    struct Sound {

        var name: String
        var file: String
        var pos: simd_float3
        var vol: Float
        var width: Int32
        var height: Int32
        var range: Float
        var cycle: Float

        init(from reader: BinaryReader, version: String) throws {
            name = try reader.readString(80, encoding: .ascii)
            file = try reader.readString(80, encoding: .ascii)
            pos = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
            vol = try reader.readFloat()
            width = try reader.readInt()
            height = try reader.readInt()
            range = try reader.readFloat()
            cycle = try version >= "2.0" ? reader.readFloat() : 0
        }
    }

    struct Effect {

        var name: String
        var pos: simd_float3
        var id: Int32
        var delay: Float
        var param: simd_float4

        init(from reader: BinaryReader, version: String) throws {
            name = try reader.readString(80, encoding: .ascii)
            pos = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
            id = try reader.readInt()
            delay = try reader.readFloat() * 10
            param = try [reader.readFloat(), reader.readFloat(), reader.readFloat(), reader.readFloat()]
        }
    }
}

struct RSWDocument {

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

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        defer {
            stream.close()
        }

        let reader = BinaryReader(stream: stream)

        header = try reader.readString(4, encoding: .ascii)
        guard header == "GRSW" else {
            throw DocumentError.invalidContents
        }

        let major: UInt8 = try reader.readInt()
        let minor: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        files = try RSWFiles(from: reader, version: version)

        water = try RSWWater(from: reader, version: version)

        light = try RSWLight(from: reader, version: version)

        ground = try RSWGround(from: reader, version: version)

        let count: Int32 = try reader.readInt()

        models = []
        lights = []
        sounds = []
        effects = []

        for _ in 0..<count {
            let type: Int32 = try reader.readInt()
            switch (type) {
            case 1:
                let model = try RSWObject.Model(from: reader, version: version)
                models.append(model)
            case 2:
                let light = try RSWObject.Light(from: reader, version: version)
                lights.append(light)
            case 3:
                let sound = try RSWObject.Sound(from: reader, version: version)
                sounds.append(sound)
            case 4:
                let effect = try RSWObject.Effect(from: reader, version: version)
                effects.append(effect)
            default:
                break
            }
        }
    }
}
