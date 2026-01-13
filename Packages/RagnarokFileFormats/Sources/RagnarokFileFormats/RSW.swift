//
//  RSW.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2020/5/19.
//

import BinaryIO
import Foundation

public struct RSW: FileFormat {
    public var header: String
    public var version: FileFormatVersion
    public var files: RSW.Files
    public var water: RSW.Water
    public var light: RSW.Light
    public var boundingBox: RSW.BoundingBox
    public var models: [RSW.Objects.Model] = []
    public var lights: [RSW.Objects.Light] = []
    public var sounds: [RSW.Objects.Sound] = []
    public var effects: [RSW.Objects.Effect] = []

    public init(from decoder: BinaryDecoder) throws {
        header = try decoder.decode(String.self, lengthOfBytes: 4)
        guard header == "GRSW" else {
            throw FileFormatError.invalidHeader(header, expected: "GRSW")
        }

        let major = try decoder.decode(UInt8.self)
        let minor = try decoder.decode(UInt8.self)
        version = FileFormatVersion(major: major, minor: minor)

        if version >= "2.5" {
            // Build number
            _ = try decoder.decode(UInt32.self)
        }

        if version >= "2.2" {
            // Unknown data
            _ = try decoder.decode(UInt8.self)
        }

        files = try decoder.decode(RSW.Files.self, configuration: version)

        water = try decoder.decode(RSW.Water.self, configuration: version)

        light = try decoder.decode(RSW.Light.self, configuration: version)

        boundingBox = try decoder.decode(RSW.BoundingBox.self, configuration: version)

        let objectCount = try decoder.decode(Int32.self)

        for _ in 0..<objectCount {
            let objectType = try RSW.Objects.ObjectType(rawValue: decoder.decode(Int32.self))
            switch objectType {
            case .model:
                let model = try decoder.decode(RSW.Objects.Model.self, configuration: version)
                models.append(model)
            case .light:
                let light = try decoder.decode(RSW.Objects.Light.self, configuration: version)
                lights.append(light)
            case .sound:
                let sound = try decoder.decode(RSW.Objects.Sound.self, configuration: version)
                sounds.append(sound)
            case .effect:
                let effect = try decoder.decode(RSW.Objects.Effect.self, configuration: version)
                effects.append(effect)
            default:
                break
            }
        }
    }
}

extension RSW {
    public struct Files: BinaryDecodableWithConfiguration, Sendable {
        public var ini: String
        public var gnd: String
        public var gat: String
        public var src: String

        public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
            ini = try decoder.decode(String.self, lengthOfBytes: 40)

            gnd = try decoder.decode(String.self, lengthOfBytes: 40)

            if version >= "1.4" {
                gat = try decoder.decode(String.self, lengthOfBytes: 40)
            } else {
                gat = ""
            }

            src = try decoder.decode(String.self, lengthOfBytes: 40)
        }
    }
}

extension RSW {
    public struct Water: BinaryDecodableWithConfiguration, Sendable {
        public var level: Float
        public var type: Int32
        public var waveHeight: Float
        public var waveSpeed: Float
        public var wavePitch: Float
        public var animationSpeed: Int32

        public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
            if version >= "2.6" {
                level = 0
                type = 0
                waveHeight = 0
                waveSpeed = 0
                wavePitch = 0
                animationSpeed = 0
                return
            }

            if version >= "1.3" {
                level = try decoder.decode(Float.self)
            } else {
                level = 0
            }

            if version >= "1.8" {
                type = try decoder.decode(Int32.self)
                waveHeight = try decoder.decode(Float.self)
                waveSpeed = try decoder.decode(Float.self)
                wavePitch = try decoder.decode(Float.self)
            } else {
                type = 0
                waveHeight = 5
                waveSpeed = 2
                wavePitch = 50
            }

            if version >= "1.9" {
                animationSpeed = try decoder.decode(Int32.self)
            } else {
                animationSpeed = 3
            }
        }
    }
}

extension RSW {
    public struct Light: BinaryDecodableWithConfiguration, Sendable {
        public var longitude: Int32
        public var latitude: Int32
        public var diffuseRed: Float
        public var diffuseGreen: Float
        public var diffuseBlue: Float
        public var ambientRed: Float
        public var ambientGreen: Float
        public var ambientBlue: Float
        public var opacity: Float

        public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
            if version >= "1.5" {
                longitude = try decoder.decode(Int32.self)
                latitude = try decoder.decode(Int32.self)
                diffuseRed = try decoder.decode(Float.self)
                diffuseGreen = try decoder.decode(Float.self)
                diffuseBlue = try decoder.decode(Float.self)
                ambientRed = try decoder.decode(Float.self)
                ambientGreen = try decoder.decode(Float.self)
                ambientBlue = try decoder.decode(Float.self)
            } else {
                longitude = 45
                latitude = 45
                diffuseRed = 1
                diffuseGreen = 1
                diffuseBlue = 1
                ambientRed = 0.3
                ambientGreen = 0.3
                ambientBlue = 0.3
            }

            if version >= "1.7" {
                opacity = try decoder.decode(Float.self)
            } else {
                opacity = 1
            }
        }
    }
}

extension RSW {
    public struct BoundingBox: BinaryDecodableWithConfiguration, Sendable {
        public var top: Int32
        public var bottom: Int32
        public var left: Int32
        public var right: Int32

        public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
            if version >= "1.6" {
                top = try decoder.decode(Int32.self)
                bottom = try decoder.decode(Int32.self)
                left = try decoder.decode(Int32.self)
                right = try decoder.decode(Int32.self)
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
    public enum Objects {
        public enum ObjectType: Int32 {
            case model = 1
            case light = 2
            case sound = 3
            case effect = 4
        }

        public struct Model: BinaryDecodableWithConfiguration, Sendable {
            public var name: String
            public var animationType: Int32
            public var animationSpeed: Float
            public var blockType: Int32
            public var modelName: String
            public var nodeName: String
            public var position: SIMD3<Float>
            public var rotation: SIMD3<Float>
            public var scale: SIMD3<Float>

            public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
                if version >= "1.3" {
                    name = try decoder.decode(String.self, lengthOfBytes: 40, encoding: .isoLatin1)
                    animationType = try decoder.decode(Int32.self)
                    animationSpeed = try decoder.decode(Float.self)
                    blockType = try decoder.decode(Int32.self)
                } else {
                    name = ""
                    animationType = 0
                    animationSpeed = 1
                    blockType = 0
                }

                modelName = try decoder.decode(String.self, lengthOfBytes: 80, encoding: .isoLatin1)
                nodeName = try  decoder.decode(String.self, lengthOfBytes: 80, encoding: .isoLatin1)
                position = try [
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                ]
                rotation = try [
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                ]
                scale = try [
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                ]
            }
        }

        public struct Light: BinaryDecodableWithConfiguration, Sendable {
            public var name: String
            public var position: SIMD3<Float>
            public var diffuseRed: Float
            public var diffuseGreen: Float
            public var diffuseBlue: Float
            public var range: Float

            public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
                name = try decoder.decode(String.self, lengthOfBytes: 80, encoding: .isoLatin1)
                position = try [
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                ]
                diffuseRed = try decoder.decode(Float.self)
                diffuseGreen = try decoder.decode(Float.self)
                diffuseBlue = try decoder.decode(Float.self)
                range = try decoder.decode(Float.self)
            }
        }

        public struct Sound: BinaryDecodableWithConfiguration, Sendable {
            public var name: String
            public var waveName: String
            public var position: SIMD3<Float>
            public var volume: Float
            public var width: Int32
            public var height: Int32
            public var range: Float
            public var cycle: Float

            public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
                name = try decoder.decode(String.self, lengthOfBytes: 80, encoding: .isoLatin1)
                waveName = try decoder.decode(String.self, lengthOfBytes: 80)
                position = try [
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                ]
                volume = try decoder.decode(Float.self)
                width = try decoder.decode(Int32.self)
                height = try decoder.decode(Int32.self)
                range = try decoder.decode(Float.self)

                if version >= "2.0" {
                    cycle = try decoder.decode(Float.self)
                } else {
                    cycle = 0
                }
            }
        }

        public struct Effect: BinaryDecodableWithConfiguration, Sendable {
            public var name: String
            public var position: SIMD3<Float>
            public var id: Int32
            public var delay: Float
            public var parameters: SIMD4<Float>

            public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
                name = try decoder.decode(String.self, lengthOfBytes: 80, encoding: .isoLatin1)
                position = try [
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                    decoder.decode(Float.self) / 5,
                ]
                id = try decoder.decode(Int32.self)
                delay = try decoder.decode(Float.self) * 10
                parameters = try [
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                ]
            }
        }
    }
}
