//
//  RSM.swift
//  FileFormats
//
//  Created by Leon Li on 2020/5/12.
//

import BinaryIO
import Foundation
import simd

public struct RSM: FileFormat {
    public var header: String
    public var version: FileFormatVersion
    public var animationLength: Int32
    public var shadeType: Int32
    public var alpha: UInt8

    public var rootNodes: [String] = []
    public var nodes: [RSM.Node] = []

    public var scaleKeyframes: [RSM.ScaleKeyframe] = []

    public var volumeBoxes: [RSM.VolumeBox] = []

    public init(from decoder: BinaryDecoder) throws {
        header = try decoder.decode(String.self, lengthOfBytes: 4)
        guard header == "GRSM" else {
            throw FileFormatError.invalidHeader(header, expected: "GRSM")
        }

        let major = try decoder.decode(UInt8.self)
        let minor = try decoder.decode(UInt8.self)
        version = FileFormatVersion(major: major, minor: minor)

        animationLength = try decoder.decode(Int32.self)

        shadeType = try decoder.decode(Int32.self)

        if version >= "1.4" {
            alpha = try decoder.decode(UInt8.self)
        } else {
            alpha = 255
        }

        var textures: [String] = []

        if version >= "2.3" {
            let fps = try decoder.decode(Float.self)
            animationLength = Int32(ceilf(Float(animationLength) * fps))

            let rootNodeCount = try decoder.decode(Int32.self)
            for _ in 0..<rootNodeCount {
                let nodeNameLength = try decoder.decode(Int32.self)
                let rootNodeName = try decoder.decode(String.self, lengthOfBytes: Int(nodeNameLength))
                rootNodes.append(rootNodeName)
            }
        } else if version >= "2.2" {
            let fps = try decoder.decode(Float.self)
            animationLength = Int32(ceilf(Float(animationLength) * fps))

            let textureCount = try decoder.decode(Int32.self)
            for _ in 0..<textureCount {
                let textureNameLength = try decoder.decode(Int32.self)
                let textureName = try decoder.decode(String.self, lengthOfBytes: Int(textureNameLength), encoding: .isoLatin1)
                textures.append(textureName)
            }

            let rootNodeCount = try decoder.decode(Int32.self)
            for _ in 0..<rootNodeCount {
                let nodeNameLength = try decoder.decode(Int32.self)
                let rootNodeName = try decoder.decode(String.self, lengthOfBytes: Int(nodeNameLength))
                rootNodes.append(rootNodeName)
            }
        } else {
            // Reserved
            _ = try decoder.decode([UInt8].self, count: 16)

            let textureCount = try decoder.decode(Int32.self)
            for _ in 0..<textureCount {
                let textureName = try decoder.decode(String.self, lengthOfBytes: 40, encoding: .isoLatin1)
                textures.append(textureName)
            }

            let rootNodeName = try decoder.decode(String.self, lengthOfBytes: 40)
            rootNodes.append(rootNodeName)
        }

        let nodeCount = try decoder.decode(Int32.self)
        for _ in 0..<nodeCount {
            let configuration = RSM.Node.BinaryDecodingConfiguration(version: version, textures: textures)
            let node = try decoder.decode(RSM.Node.self, configuration: configuration)
            nodes.append(node)
        }

        if rootNodes.isEmpty, let firstNode = nodes.first {
            rootNodes.append(firstNode.name)
        }

        if version < "1.6" {
            let scaleKeyframeCount = try decoder.decode(Int32.self)
            for _ in 0..<scaleKeyframeCount {
                let keyframe = try decoder.decode(RSM.ScaleKeyframe.self)
                scaleKeyframes.append(keyframe)
            }
        }

        if decoder.bytesRemaining > 0 {
            let volumeBoxCount = try decoder.decode(Int32.self)
            for _ in 0..<volumeBoxCount {
                let volumeBox = try decoder.decode(RSM.VolumeBox.self, configuration: version)
                volumeBoxes.append(volumeBox)
            }
        }
    }
}

extension RSM {
    public enum RSMShadingType: Int32 {
        case none = 0
        case flat = 1
        case smooth = 2
    }
}

extension RSM {
    public struct Node: BinaryDecodableWithConfiguration, Sendable {
        public struct BinaryDecodingConfiguration {
            public var version: FileFormatVersion
            public var textures: [String]
        }

        public struct TextureVertex: Sendable {
            public var color: UInt32
            public var u: Float
            public var v: Float
        }

        public var name: String
        public var parentName: String

        public var textures: [String] = []

        public var transformMatrix: simd_float3x3
        public var offset: SIMD3<Float>
        public var position: SIMD3<Float>
        public var rotationAngle: Float
        public var rotationAxis: SIMD3<Float>
        public var scale: SIMD3<Float>

        public var vertices: [SIMD3<Float>] = []
        public var tvertices: [RSM.Node.TextureVertex] = []

        public var faces: [RSM.Face] = []

        public var scaleKeyframes: [RSM.ScaleKeyframe] = []
        public var rotationKeyframes: [RSM.RotationKeyframe] = []
        public var positionKeyframes: [RSM.PositionKeyframe] = []

        public init(from decoder: BinaryDecoder, configuration: BinaryDecodingConfiguration) throws {
            let version = configuration.version

            if version >= "2.2" {
                let nameLength = try decoder.decode(Int32.self)
                name = try decoder.decode(String.self, lengthOfBytes: Int(nameLength))

                let parentNameLength = try decoder.decode(Int32.self)
                parentName = try decoder.decode(String.self, lengthOfBytes: Int(parentNameLength))
            } else {
                name = try decoder.decode(String.self, lengthOfBytes: 40)
                parentName = try decoder.decode(String.self, lengthOfBytes: 40)
            }

            if version >= "2.3" {
                let textureCount = try decoder.decode(Int32.self)
                for _ in 0..<textureCount {
                    let textureNameLength = try decoder.decode(Int32.self)
                    let textureName = try decoder.decode(String.self, lengthOfBytes: Int(textureNameLength))
                    textures.append(textureName)
                }
            } else {
                let textureCount = try decoder.decode(Int32.self)
                for _ in 0..<textureCount {
                    let textureIndex = try decoder.decode(Int32.self)
                    let textureName = configuration.textures[Int(textureIndex)]
                    textures.append(textureName)
                }
            }

            let col0: SIMD3<Float> = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            let col1: SIMD3<Float> = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            let col2: SIMD3<Float> = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            transformMatrix = simd_float3x3(col0, col1, col2)

            offset = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]

            if version >= "2.2" {
                position = [0, 0, 0]
                rotationAngle = 0
                rotationAxis = [0, 0, 0]
                scale = [1, 1, 1]
            } else {
                position = try [
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                ]
                rotationAngle = try decoder.decode(Float.self)
                rotationAxis = try [
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                ]
                scale = try [
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                ]
            }

            let vertexCount = try decoder.decode(Int32.self)
            for _ in 0..<vertexCount {
                let vertex: SIMD3<Float> = try [
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                ]
                vertices.append(vertex)
            }

            let tvertexCount = try decoder.decode(Int32.self)
            for _ in 0..<tvertexCount {
                let color: UInt32
                if version >= "1.2" {
                    color = try decoder.decode(UInt32.self)
                } else {
                    color = 0xffffffff
                }
                let u = try decoder.decode(Float.self)
                let v = try decoder.decode(Float.self)
                let textureVertex = RSM.Node.TextureVertex(color: color, u: u, v: v)
                tvertices.append(textureVertex)
            }

            let faceCount = try decoder.decode(Int32.self)
            for _ in 0..<faceCount {
                let face = try decoder.decode(RSM.Face.self, configuration: version)
                faces.append(face)
            }

            if version >= "1.6" {
                let scaleKeyframeCount = try decoder.decode(Int32.self)
                for _ in 0..<scaleKeyframeCount {
                    let keyframe = try decoder.decode(RSM.ScaleKeyframe.self)
                    scaleKeyframes.append(keyframe)
                }
            }

            let rotationKeyframeCount = try decoder.decode(Int32.self)
            for _ in 0..<rotationKeyframeCount {
                let keyframe = try decoder.decode(RSM.RotationKeyframe.self)
                rotationKeyframes.append(keyframe)
            }

            if version >= "2.2" {
                let positionKeyframeCount = try decoder.decode(Int32.self)
                for _ in 0..<positionKeyframeCount {
                    let keyframe = try decoder.decode(RSM.PositionKeyframe.self)
                    positionKeyframes.append(keyframe)
                }
            }

            if version >= "2.3" {
                let textureAnimationCount = try decoder.decode(Int32.self)
                for _ in 0..<textureAnimationCount {
                    let textureIndex = try decoder.decode(Int32.self)

                    let textureAnimationCount = try decoder.decode(Int32.self)
                    for _ in 0..<textureAnimationCount {
                        let type = try decoder.decode(Int32.self)

                        let frameCount = try decoder.decode(Int32.self)
                        for _ in 0..<frameCount {
                            let frame = try decoder.decode(Int32.self)
                            let data = try decoder.decode(Float.self)
                        }
                    }
                }
            }
        }
    }
}

extension RSM {
    public struct Face: BinaryDecodableWithConfiguration, Sendable {
        public var vertexIndices: SIMD3<Int16>
        public var tvertexIndices: SIMD3<Int16>
        public var textureIndex: Int16
        public var padding: Int16
        public var twoSided: Int32
        public var smoothGroup: SIMD3<Int32>

        public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
            var length: Int32 = -1
            if version >= "2.2" {
                length = try decoder.decode(Int32.self)
            }

            vertexIndices = try [
                decoder.decode(Int16.self),
                decoder.decode(Int16.self),
                decoder.decode(Int16.self),
            ]
            tvertexIndices = try [
                decoder.decode(Int16.self),
                decoder.decode(Int16.self),
                decoder.decode(Int16.self),
            ]
            textureIndex = try decoder.decode(Int16.self)
            padding = try decoder.decode(Int16.self)
            twoSided = try decoder.decode(Int32.self)

            if version >= "1.2" {
                let smooth = try decoder.decode(Int32.self)
                smoothGroup = [smooth, smooth, smooth]

                if length > 24 {
                    smoothGroup[1] = try decoder.decode(Int32.self)
                }

                if length > 28 {
                    smoothGroup[2] = try decoder.decode(Int32.self)
                }

                if length > 32 {
                    _ = try decoder.decode([UInt8].self, count: Int(length) - 32)
                }
            } else {
                smoothGroup = [0, 0, 0]
            }
        }
    }
}

extension RSM {
    public struct ScaleKeyframe: BinaryDecodable, Sendable {
        public var frame: Int32
        public var scale: SIMD3<Float>
        public var data: Float

        public init(from decoder: BinaryDecoder) throws {
            frame = try decoder.decode(Int32.self)
            scale = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            data = try decoder.decode(Float.self)
        }
    }

    public struct RotationKeyframe: BinaryDecodable, Sendable {
        public var frame: Int32
        public var quaternion: simd_quatf

        public init(from decoder: BinaryDecoder) throws {
            frame = try decoder.decode(Int32.self)
            quaternion = try simd_quatf(
                ix: decoder.decode(Float.self),
                iy: decoder.decode(Float.self),
                iz: decoder.decode(Float.self),
                r: decoder.decode(Float.self)
            )
        }
    }

    public struct PositionKeyframe: BinaryDecodable, Sendable {
        public var frame: Int32
        public var position: SIMD3<Float>
        public var data: Int32

        public init(from decoder: BinaryDecoder) throws {
            frame = try decoder.decode(Int32.self)
            position = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            data = try decoder.decode(Int32.self)
        }
    }
}

extension RSM {
    public struct VolumeBox: BinaryDecodableWithConfiguration, Sendable {
        public var size: SIMD3<Float>
        public var position: SIMD3<Float>
        public var rotation: SIMD3<Float>
        public var flag: Int32

        public init(from decoder: BinaryDecoder, configuration version: FileFormatVersion) throws {
            size = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            position = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
            rotation = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]

            if version >= "1.3" {
                flag = try decoder.decode(Int32.self)
            } else {
                flag = 0
            }
        }
    }
}
