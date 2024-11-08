//
//  RSM.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/12.
//

import Foundation
import simd
import ROCore

public struct RSM: BinaryDecodable {
    public var header: String
    public var version: String
    public var animationLength: Int32
    public var shadeType: Int32
    public var alpha: UInt8

    public var textures: [String] = []

    public var rootNodes: [String] = []
    public var nodes: [Node] = []

    public var scaleKeyframes: [ScaleKeyframe] = []

    public var volumeBoxes: [VolumeBox] = []

    public init(data: Data) throws {
        let decoder = BinaryDecoder(data: data)
        self = try decoder.decode(RSM.self)
    }

    public init(from decoder: BinaryDecoder) throws {
        header = try decoder.decodeString(4)
        guard header == "GRSM" else {
            throw FileFormatError.invalidHeader(header, expected: "GRSM")
        }

        let major = try decoder.decode(UInt8.self)
        let minor = try decoder.decode(UInt8.self)
        version = "\(major).\(minor)"

        animationLength = try decoder.decode(Int32.self)

        shadeType = try decoder.decode(Int32.self)

        if version >= "1.4" {
            alpha = try decoder.decode(UInt8.self)
        } else {
            alpha = 255
        }

        if version >= "2.3" {
            let fps = try decoder.decode(Float.self)

            let rootNodeCount = try decoder.decode(Int32.self)
            for _ in 0..<rootNodeCount {
                let nodeNameLength = try decoder.decode(Int32.self)
                let rootNodeName = try decoder.decodeString(Int(nodeNameLength))
                rootNodes.append(rootNodeName)
            }

            let nodeCount = try decoder.decode(Int32.self)
            for _ in 0..<nodeCount {
                let node = try decoder.decode(Node.self, configuration: version)
                nodes.append(node)
            }
        } else if version >= "2.2" {
            let fps = try decoder.decode(Float.self)

            let textureCount = try decoder.decode(Int32.self)
            for _ in 0..<textureCount {
                let textureNameLength = try decoder.decode(Int32.self)
                let texture = try decoder.decodeString(Int(textureNameLength), encoding: .koreanEUC)
                textures.append(texture)
            }

            let rootNodeCount = try decoder.decode(Int32.self)
            for _ in 0..<rootNodeCount {
                let nodeNameLength = try decoder.decode(Int32.self)
                let rootNodeName = try decoder.decodeString(Int(nodeNameLength))
                rootNodes.append(rootNodeName)
            }

            let nodeCount = try decoder.decode(Int32.self)
            for _ in 0..<nodeCount {
                let node = try decoder.decode(Node.self, configuration: version)
                nodes.append(node)
            }
        } else {
            // Reserved
            _ = try decoder.decodeBytes(16)

            let textureCount = try decoder.decode(Int32.self)
            for _ in 0..<textureCount {
                let texture = try decoder.decodeString(40, encoding: .koreanEUC)
                textures.append(texture)
            }

            let rootNode = try decoder.decodeString(40)
            rootNodes.append(rootNode)

            let nodeCount = try decoder.decode(Int32.self)
            for _ in 0..<nodeCount {
                let node = try decoder.decode(Node.self, configuration: version)
                nodes.append(node)
            }
        }

        if rootNodes.isEmpty, let firstNode = nodes.first {
            rootNodes.append(firstNode.name)
        }

        if version < "1.6" {
            let scaleKeyframeCount = try decoder.decode(Int32.self)
            for _ in 0..<scaleKeyframeCount {
                let keyframe = try decoder.decode(ScaleKeyframe.self)
                scaleKeyframes.append(keyframe)
            }
        }

        if decoder.bytesRemaining > 0 {
            let volumeBoxCount = try decoder.decode(Int32.self)
            for _ in 0..<volumeBoxCount {
                let volumeBox = try decoder.decode(VolumeBox.self, configuration: version)
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
    public struct Node: BinaryDecodableWithConfiguration {
        public struct TextureVertex {
            public var color: UInt32
            public var u: Float
            public var v: Float
        }

        public var name: String
        public var parentName: String

        public var textures: [String] = []
        public var textureIndexes: [Int32] = []

        public var transformationMatrix: float3x3
        public var offset: SIMD3<Float>
        public var position: SIMD3<Float>
        public var rotationAngle: Float
        public var rotationAxis: SIMD3<Float>
        public var scale: SIMD3<Float>

        public var vertices: [SIMD3<Float>] = []
        public var tvertices: [TextureVertex] = []

        public var faces: [Face] = []

        public var scaleKeyframes: [ScaleKeyframe] = []
        public var rotationKeyframes: [RotationKeyframe] = []
        public var positionKeyframes: [PositionKeyframe] = []

        public init(from decoder: BinaryDecoder, configuration version: String) throws {
            if version >= "2.2" {
                let nameLength = try decoder.decode(Int32.self)
                name = try decoder.decodeString(Int(nameLength))

                let parentNameLength = try decoder.decode(Int32.self)
                parentName = try decoder.decodeString(Int(parentNameLength))
            } else {
                name = try decoder.decodeString(40)
                parentName = try decoder.decodeString(40)
            }

            if version >= "2.3" {
                let textureCount = try decoder.decode(Int32.self)
                for textureIndex in 0..<textureCount {
                    let textureNameLength = try decoder.decode(Int32.self)
                    let texture = try decoder.decodeString(Int(textureNameLength))
                    textures.append(texture)
                    textureIndexes.append(textureIndex)
                }
            } else {
                let textureCount = try decoder.decode(Int32.self)
                for _ in 0..<textureCount {
                    let texture = try decoder.decode(Int32.self)
                    textureIndexes.append(texture)
                }
            }

            transformationMatrix = try float3x3(
                [
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                ],
                [
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                ],
                [
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                    decoder.decode(Float.self),
                ]
            )

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
                    color = 0xFFFFFFFF
                }
                let u = try decoder.decode(Float.self)
                let v = try decoder.decode(Float.self)
                let textureVertex = TextureVertex(color: color, u: u, v: v)
                tvertices.append(textureVertex)
            }

            let faceCount = try decoder.decode(Int32.self)
            for _ in 0..<faceCount {
                let face = try decoder.decode(Face.self, configuration: version)
                faces.append(face)
            }

            if version >= "1.6" {
                let scaleKeyframeCount = try decoder.decode(Int32.self)
                for _ in 0..<scaleKeyframeCount {
                    let keyframe = try decoder.decode(ScaleKeyframe.self)
                    scaleKeyframes.append(keyframe)
                }
            }

            let rotationKeyframeCount = try decoder.decode(Int32.self)
            for _ in 0..<rotationKeyframeCount {
                let keyframe = try decoder.decode(RotationKeyframe.self)
                rotationKeyframes.append(keyframe)
            }

            if version >= "2.2" {
                let positionKeyframeCount = try decoder.decode(Int32.self)
                for _ in 0..<positionKeyframeCount {
                    let keyframe = try decoder.decode(PositionKeyframe.self)
                    positionKeyframes.append(keyframe)
                }
            }

//            if (version >= 2.3) {
//                count = reader.Int32();
//
//                for (int i = 0; i < count; i++) {
//                    int textureId = reader.Int32();
//                    int amountTextureAnimations = reader.Int32();
//
//                    for (int j = 0; j < amountTextureAnimations; j++) {
//                        int type = reader.Int32();
//                        int amountFrames = reader.Int32();
//
//                        for (int k = 0; k < amountFrames; k++) {
//                            _textureKeyFrameGroup.AddTextureKeyFrame(textureId, type, new TextureKeyFrame {
//                                Frame = reader.Int32(),
//                                Offset = reader.Float()
//                            });
//                        }
//                    }
//                }
//            }
        }
    }
}

extension RSM {
    public struct Face: BinaryDecodableWithConfiguration {
        public var vertidx: SIMD3<UInt16>
        public var tvertidx: SIMD3<UInt16>
        public var textureIndex: UInt16
        public var padding: UInt16
        public var twoSide: Int32
        public var smoothGroup: SIMD3<Int32>

        public init(from decoder: BinaryDecoder, configuration version: String) throws {
            var length: Int32 = -1
            if version >= "2.2" {
                length = try decoder.decode(Int32.self)
            }

            vertidx = try [
                decoder.decode(UInt16.self),
                decoder.decode(UInt16.self),
                decoder.decode(UInt16.self),
            ]
            tvertidx = try [
                decoder.decode(UInt16.self),
                decoder.decode(UInt16.self),
                decoder.decode(UInt16.self),
            ]
            textureIndex = try decoder.decode(UInt16.self)
            padding = try decoder.decode(UInt16.self)
            twoSide = try decoder.decode(Int32.self)

            if version >= "1.2" {
                let smooth: Int32 = try decoder.decode(Int32.self)
                smoothGroup = [smooth, smooth, smooth]

                if length > 24 {
                    smoothGroup[1] = try decoder.decode(Int32.self)
                }

                if length > 28 {
                    smoothGroup[2] = try decoder.decode(Int32.self)
                }

                if length > 32 {
                    _ = try decoder.decodeBytes(Int(length) - 32)
                }
            } else {
                smoothGroup = [0, 0, 0]
            }
        }
    }
}

extension RSM {
    public struct ScaleKeyframe: BinaryDecodable {
        public var frame: Int32
        public var sx: Float
        public var sy: Float
        public var sz: Float
        public var data: Float

        public init(from decoder: BinaryDecoder) throws {
            frame = try decoder.decode(Int32.self)
            sx = try decoder.decode(Float.self)
            sy = try decoder.decode(Float.self)
            sz = try decoder.decode(Float.self)
            data = try decoder.decode(Float.self)
        }
    }

    public struct RotationKeyframe: BinaryDecodable {
        public var frame: Int32
        public var quaternion: SIMD4<Float>

        public init(from decoder: BinaryDecoder) throws {
            frame = try decoder.decode(Int32.self)
            quaternion = try [
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
                decoder.decode(Float.self),
            ]
        }
    }

    public struct PositionKeyframe: BinaryDecodable {
        public var frame: Int32
        public var px: Float
        public var py: Float
        public var pz: Float
        public var data: Int32

        public init(from decoder: BinaryDecoder) throws {
            frame = try decoder.decode(Int32.self)
            px = try decoder.decode(Float.self)
            py = try decoder.decode(Float.self)
            pz = try decoder.decode(Float.self)
            data = try decoder.decode(Int32.self)
        }
    }
}

extension RSM {
    public struct VolumeBox: BinaryDecodableWithConfiguration {
        public var size: SIMD3<Float>
        public var position: SIMD3<Float>
        public var rotation: SIMD3<Float>
        public var flag: Int32

        public init(from decoder: BinaryDecoder, configuration version: String) throws {
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
