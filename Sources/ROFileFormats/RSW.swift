//
//  RSW.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/19.
//

import Foundation
import simd
import ROStream

public struct RSW: Encodable {
    public var header: String
    public var version: String
    public var files: Files
    public var water: Water
    public var light: Light
    public var boundingBox: BoundingBox
    public var models: [Object.Model] = []
    public var lights: [Object.Light] = []
    public var sounds: [Object.Sound] = []
    public var effects: [Object.Effect] = []

    public init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(4)
        guard header == "GRSW" else {
            throw DocumentError.invalidContents
        }

        let major: UInt8 = try reader.readInt()
        let minor: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        if version >= "2.5" {
            // Build number
            _ = try reader.readInt() as UInt32
        }

        if version >= "2.2" {
            // Unknown data
            _ = try reader.readInt() as UInt8
        }

        files = try Files(from: reader, version: version)

        water = try Water(from: reader, version: version)

        light = try Light(from: reader, version: version)

        boundingBox = try BoundingBox(from: reader, version: version)

        let objectCount: Int32 = try reader.readInt()

        for _ in 0..<objectCount {
            let objectType = try Object.ObjectType(rawValue: reader.readInt())
            switch objectType {
            case .model:
                let model = try Object.Model(from: reader, version: version)
                models.append(model)
            case .light:
                let light = try Object.Light(from: reader, version: version)
                lights.append(light)
            case .sound:
                let sound = try Object.Sound(from: reader, version: version)
                sounds.append(sound)
            case .effect:
                let effect = try Object.Effect(from: reader, version: version)
                effects.append(effect)
            default:
                break
            }
        }
    }
}

extension RSW {
    public struct Files: Encodable {
        public var ini: String
        public var gnd: String
        public var gat: String
        public var src: String

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
    public struct Water: Encodable {
        public var level: Float
        public var type: Int32
        public var waveHeight: Float
        public var waveSpeed: Float
        public var wavePitch: Float
        public var animSpeed: Int32

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
    public struct Light: Encodable {
        public var longitude: Int32
        public var latitude: Int32
        public var diffuse: DiffuseColor
        public var ambient: AmbientColor
        public var opacity: Float

        init(from reader: BinaryReader, version: String) throws {
            if version >= "1.5" {
                longitude = try reader.readInt()
                latitude = try reader.readInt()
                diffuse = try DiffuseColor(from: reader)
                ambient = try AmbientColor(from: reader)
            } else {
                longitude = 45
                latitude = 45
                diffuse = DiffuseColor(red: 1, green: 1, blue: 1)
                ambient = AmbientColor(red: 0.3, green: 0.3, blue: 0.3)
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
    public struct BoundingBox: Encodable {
        public var top: Int32
        public var bottom: Int32
        public var left: Int32
        public var right: Int32

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
    public enum Object {
        public enum ObjectType: Int32 {
            case model = 1
            case light = 2
            case sound = 3
            case effect = 4
        }

        public struct Model: Encodable {
            public var name: String
            public var animationType: Int32
            public var animationSpeed: Float
            public var blockType: Int32
            public var modelName: String
            public var nodeName: String
            public var position: simd_float3
            public var rotation: simd_float3
            public var scale: simd_float3

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

        public struct Light: Encodable {
            public var name: String
            public var position: simd_float3
            public var diffuse: DiffuseColor
            public var range: Float

            init(from reader: BinaryReader, version: String) throws {
                name = try reader.readString(80, encoding: .koreanEUC)
                position = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
                diffuse = try DiffuseColor(from: reader)
                range = try reader.readFloat()
            }
        }

        public struct Sound: Encodable {
            public var name: String
            public var waveName: String
            public var position: simd_float3
            public var volume: Float
            public var width: Int32
            public var height: Int32
            public var range: Float
            public var cycle: Float

            init(from reader: BinaryReader, version: String) throws {
                name = try reader.readString(80, encoding: .koreanEUC)
                waveName = try reader.readString(80)
                position = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
                volume = try reader.readFloat()
                width = try reader.readInt()
                height = try reader.readInt()
                range = try reader.readFloat()
                cycle = try version >= "2.0" ? reader.readFloat() : 0
            }
        }

        public struct Effect: Encodable {
            public var name: String
            public var position: simd_float3
            public var id: Int32
            public var delay: Float
            public var parameters: simd_float4

            init(from reader: BinaryReader, version: String) throws {
                name = try reader.readString(80, encoding: .koreanEUC)
                position = try [reader.readFloat() / 5, reader.readFloat() / 5, reader.readFloat() / 5]
                id = try reader.readInt()
                delay = try reader.readFloat() * 10
                parameters = try [
                    reader.readFloat(),
                    reader.readFloat(),
                    reader.readFloat(),
                    reader.readFloat()
                ]
            }
        }
    }
}
