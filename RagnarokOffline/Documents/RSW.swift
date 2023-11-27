//
//  RSW.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/19.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import simd

struct RSW {
    var header: Header
    var files: Files
    var water: Water
    var light: Light
    var ground: Ground
    var models: [Object.Model] = []
    var lights: [Object.Light] = []
    var sounds: [Object.Sound] = []
    var effects: [Object.Effect] = []

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try Header(from: reader)

        if header.version >= "2.5" {
            // Build number
            _ = try reader.readInt() as UInt32
        }

        if header.version >= "2.2" {
            // Unknown data
            _ = try reader.readInt() as UInt8
        }

        files = try Files(from: reader, version: header.version)

        water = try Water(from: reader, version: header.version)

        light = try Light(from: reader, version: header.version)

        ground = try Ground(from: reader, version: header.version)

        let objectCount: Int32 = try reader.readInt()

        for _ in 0..<objectCount {
            let objectType = try Object.ObjectType(rawValue: reader.readInt())
            switch objectType {
            case .model:
                let model = try Object.Model(from: reader, version: header.version)
                models.append(model)
            case .light:
                let light = try Object.Light(from: reader, version: header.version)
                lights.append(light)
            case .sound:
                let sound = try Object.Sound(from: reader, version: header.version)
                sounds.append(sound)
            case .effect:
                let effect = try Object.Effect(from: reader, version: header.version)
                effects.append(effect)
            default:
                break
            }
        }
    }
}

extension RSW {
    struct Header {
        var magic: String
        var version: String

        init(from reader: BinaryReader) throws {
            magic = try reader.readString(4)
            guard magic == "GRSW" else {
                throw DocumentError.invalidContents
            }

            let major: UInt8 = try reader.readInt()
            let minor: UInt8 = try reader.readInt()
            version = "\(major).\(minor)"
        }
    }
}

extension RSW {
    struct Files {
        var ini: String
        var gnd: String
        var gat: String
        var src: String

        init(from reader: BinaryReader, version: String) throws {
            ini = try reader.readString(40)

            gnd = try reader.readString(40)

            if version >= "1.4" {
                gat = try reader.readString(40)
            } else {
                gat = ""
            }

            src = try reader.readString(40)
        }
    }
}

extension RSW {
    struct Water {
        var level: Float
        var type: Int32
        var waveHeight: Float
        var waveSpeed: Float
        var wavePitch: Float
        var animSpeed: Int32

        init(from reader: BinaryReader, version: String) throws {
            if version >= "2.6" {
                level = 0
                type = 0
                waveHeight = 0
                waveSpeed = 0
                wavePitch = 0
                animSpeed = 0
                return
            }

            if version >= "1.3" {
                level = try reader.readFloat()
            } else {
                level = 0
            }

            if version >= "1.8" {
                type = try reader.readInt()
                waveHeight = try reader.readFloat()
                waveSpeed = try reader.readFloat()
                wavePitch = try reader.readFloat()
            } else {
                type = 0
                waveHeight = 1
                waveSpeed = 2
                wavePitch = 50
            }

            if version >= "1.9" {
                animSpeed = try reader.readInt()
            } else {
                animSpeed = 3
            }
        }
    }
}

extension RSW {
    struct Light {
        typealias Diffuse = (red: Float, green: Float, blue: Float)
        typealias Ambient = (red: Float, green: Float, blue: Float)

        var longitude: Int32
        var latitude: Int32
        var diffuse: Diffuse
        var ambient: Ambient
        var opacity: Float

        init(from reader: BinaryReader, version: String) throws {
            if version >= "1.5" {
                longitude = try reader.readInt()
                latitude = try reader.readInt()
                diffuse = try (reader.readFloat(), reader.readFloat(), reader.readFloat())
                ambient = try (reader.readFloat(), reader.readFloat(), reader.readFloat())
            } else {
                longitude = 45
                latitude = 45
                diffuse = (1, 1, 1)
                ambient = (0.3, 0.3, 0.3)
            }

            if version >= "1.7" {
                opacity = try reader.readFloat()
            } else {
                opacity = 1
            }
        }
    }
}

extension RSW {
    struct Ground {
        var top: Int32
        var bottom: Int32
        var left: Int32
        var right: Int32

        init(from reader: BinaryReader, version: String) throws {
            if version >= "1.6" {
                top = try reader.readInt()
                bottom = try reader.readInt()
                left = try reader.readInt()
                right = try reader.readInt()
            } else {
                top = -500
                bottom = 500
                left = -500
                right = 500
            }
        }
    }
}

extension RSW {
    enum Object {
        enum ObjectType: Int32 {
            case model = 1
            case light = 2
            case sound = 3
            case effect = 4
        }

        struct Model {
            var name: String
            var animationType: Int32
            var animationSpeed: Float
            var blockType: Int32
            var modelName: String
            var nodeName: String
            var position: simd_float3
            var rotation: simd_float3
            var scale: simd_float3

            init(from reader: BinaryReader, version: String) throws {
                if version >= "1.3" {
                    name = try reader.readString(40, encoding: .koreanEUC)
                    animationType = try reader.readInt()
                    animationSpeed = try reader.readFloat()
                    blockType = try reader.readInt()
                } else {
                    name = ""
                    animationType = 0
                    animationSpeed = 1
                    blockType = 0
                }

                modelName = try reader.readString(80, encoding: .koreanEUC)
                nodeName = try  reader.readString(80)
                position = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
                rotation = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
                scale = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
            }
        }

        struct Light {
            var name: String
            var position: simd_float3
            var color: simd_int3
            var range: Float

            init(from reader: BinaryReader, version: String) throws {
                name = try reader.readString(80)
                position = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
                color = try [reader.readInt(), reader.readInt(), reader.readInt()]
                range = try reader.readFloat()
            }
        }

        struct Sound {
            var name: String
            var waveName: String
            var position: simd_float3
            var volume: Float
            var width: Int32
            var height: Int32
            var range: Float
            var cycle: Float

            init(from reader: BinaryReader, version: String) throws {
                name = try reader.readString(80)
                waveName = try reader.readString(80)
                position = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
                volume = try reader.readFloat()
                width = try reader.readInt()
                height = try reader.readInt()
                range = try reader.readFloat()
                cycle = try version >= "2.0" ? reader.readFloat() : 0
            }
        }

        struct Effect {
            var name: String
            var position: simd_float3
            var id: Int32
            var delay: Float
            var param: simd_float4

            init(from reader: BinaryReader, version: String) throws {
                name = try reader.readString(80)
                position = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
                id = try reader.readInt()
                delay = try reader.readFloat() * 10
                param = try [reader.readFloat(), reader.readFloat(), reader.readFloat(), reader.readFloat()]
            }
        }
    }
}
