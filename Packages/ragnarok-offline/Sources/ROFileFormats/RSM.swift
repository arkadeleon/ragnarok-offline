//
//  RSM.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/12.
//

import Foundation
import simd
import ROStream

public struct RSM: Encodable {
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
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(4)
        guard header == "GRSM" else {
            throw FileFormatError.invalidHeader(header, expected: "GRSM")
        }

        let major: UInt8 = try reader.readInt()
        let minor: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        animationLength = try reader.readInt()

        shadeType = try reader.readInt()

        if version >= "1.4" {
            alpha = try reader.readInt()
        } else {
            alpha = 255
        }

        if version >= "2.3" {
            let fps: Float = try reader.readFloat()

            let rootNodeCount: Int32 = try reader.readInt()
            for _ in 0..<rootNodeCount {
                let nodeNameLength: Int32 = try reader.readInt()
                let rootNodeName = try reader.readString(Int(nodeNameLength))
                rootNodes.append(rootNodeName)
            }

            let nodeCount: Int32 = try reader.readInt()
            for _ in 0..<nodeCount {
                let node = try Node(from: reader, version: version)
                nodes.append(node)
            }
        } else if version >= "2.2" {
            let fps: Float = try reader.readFloat()

            let textureCount: Int32 = try reader.readInt()
            for _ in 0..<textureCount {
                let textureNameLength: Int32 = try reader.readInt()
                let texture = try reader.readString(Int(textureNameLength), encoding: .koreanEUC)
                textures.append(texture)
            }

            let rootNodeCount: Int32 = try reader.readInt()
            for _ in 0..<rootNodeCount {
                let nodeNameLength: Int32 = try reader.readInt()
                let rootNodeName = try reader.readString(Int(nodeNameLength))
                rootNodes.append(rootNodeName)
            }

            let nodeCount: Int32 = try reader.readInt()
            for _ in 0..<nodeCount {
                let node = try Node(from: reader, version: version)
                nodes.append(node)
            }
        } else {
            // Reserved
            _ = try reader.readBytes(16)

            let textureCount: Int32 = try reader.readInt()
            for _ in 0..<textureCount {
                let texture = try reader.readString(40, encoding: .koreanEUC)
                textures.append(texture)
            }

            let rootNode = try reader.readString(40)
            rootNodes.append(rootNode)

            let nodeCount: Int32 = try reader.readInt()
            for _ in 0..<nodeCount {
                let node = try Node(from: reader, version: version)
                nodes.append(node)
            }
        }

        if rootNodes.isEmpty, let firstNode = nodes.first {
            rootNodes.append(firstNode.name)
        }

        if version < "1.6" {
            let scaleKeyframeCount: Int32 = try reader.readInt()
            for _ in 0..<scaleKeyframeCount {
                let keyframe = try ScaleKeyframe(from: reader)
                scaleKeyframes.append(keyframe)
            }
        }

        if reader.stream.length > reader.stream.position {
            let volumeBoxCount: Int32 = try reader.readInt()
            for _ in 0..<volumeBoxCount {
                let volumeBox = try VolumeBox(from: reader, version: version)
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
    public struct Node: Encodable {
        public struct TextureVertex: Encodable {
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

        init(from reader: BinaryReader, version: String) throws {
            if version >= "2.2" {
                let nameLength: Int32 = try reader.readInt()
                name = try reader.readString(Int(nameLength))

                let parentNameLength: Int32 = try reader.readInt()
                parentName = try reader.readString(Int(parentNameLength))
            } else {
                name = try reader.readString(40)
                parentName = try reader.readString(40)
            }

            if version >= "2.3" {
                let textureCount: Int32 = try reader.readInt()
                for textureIndex in 0..<textureCount {
                    let textureNameLength: Int32 = try reader.readInt()
                    let texture = try reader.readString(Int(textureNameLength))
                    textures.append(texture)
                    textureIndexes.append(textureIndex)
                }
            } else {
                let textureCount: Int32 = try reader.readInt()
                for _ in 0..<textureCount {
                    let texture: Int32 = try reader.readInt()
                    textureIndexes.append(texture)
                }
            }

            transformationMatrix = try float3x3(
                [reader.readFloat(), reader.readFloat(), reader.readFloat()],
                [reader.readFloat(), reader.readFloat(), reader.readFloat()],
                [reader.readFloat(), reader.readFloat(), reader.readFloat()]
            )

            offset = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]

            if version >= "2.2" {
                position = [0, 0, 0]
                rotationAngle = 0
                rotationAxis = [0, 0, 0]
                scale = [1, 1, 1]
            } else {
                position = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
                rotationAngle = try reader.readFloat()
                rotationAxis = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
                scale = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
            }

            let vertexCount: Int32 = try reader.readInt()
            for _ in 0..<vertexCount {
                let vertex: float3 = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
                vertices.append(vertex)
            }

            let tvertexCount: Int32 = try reader.readInt()
            for _ in 0..<tvertexCount {
                let color: UInt32
                if version >= "1.2" {
                    color = try reader.readInt()
                } else {
                    color = 0xFFFFFFFF
                }
                let u: Float = try reader.readFloat()
                let v: Float = try reader.readFloat()
                let textureVertex = TextureVertex(color: color, u: u, v: v)
                tvertices.append(textureVertex)
            }

            let faceCount: Int32 = try reader.readInt()
            for _ in 0..<faceCount {
                let face = try Face(from: reader, version: version)
                faces.append(face)
            }

            if version >= "1.6" {
                let scaleKeyframeCount: Int32 = try reader.readInt()
                for _ in 0..<scaleKeyframeCount {
                    let keyframe = try ScaleKeyframe(from: reader)
                    scaleKeyframes.append(keyframe)
                }
            }

            let rotationKeyframeCount: Int32 = try reader.readInt()
            for _ in 0..<rotationKeyframeCount {
                let keyframe = try RotationKeyframe(from: reader)
                rotationKeyframes.append(keyframe)
            }

            if version >= "2.2" {
                let positionKeyframeCount: Int32 = try reader.readInt()
                for _ in 0..<positionKeyframeCount {
                    let keyframe = try PositionKeyframe(from: reader)
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
    public struct Face: Encodable {
        public var vertidx: SIMD3<UInt16>
        public var tvertidx: SIMD3<UInt16>
        public var textureIndex: UInt16
        public var padding: UInt16
        public var twoSide: Int32
        public var smoothGroup: SIMD3<Int32>

        init(from reader: BinaryReader, version: String) throws {
            var length: Int32 = -1
            if version >= "2.2" {
                length = try reader.readInt()
            }

            vertidx = try [reader.readInt(), reader.readInt(), reader.readInt()]
            tvertidx = try [reader.readInt(), reader.readInt(), reader.readInt()]
            textureIndex = try reader.readInt()
            padding = try reader.readInt()
            twoSide = try reader.readInt()

            if version >= "1.2" {
                let smooth: Int32 = try reader.readInt()
                smoothGroup = [smooth, smooth, smooth]

                if length > 24 {
                    smoothGroup[1] = try reader.readInt()
                }

                if length > 28 {
                    smoothGroup[2] = try reader.readInt()
                }

                if length > 32 {
                    try reader.stream.seek(Int(length) - 32, origin: .current)
                }
            } else {
                smoothGroup = [0, 0, 0]
            }
        }
    }
}

extension RSM {
    public struct ScaleKeyframe: Encodable {
        public var frame: Int32
        public var sx: Float
        public var sy: Float
        public var sz: Float
        public var data: Float

        init(from reader: BinaryReader) throws {
            frame = try reader.readInt()
            sx = try reader.readFloat()
            sy = try reader.readFloat()
            sz = try reader.readFloat()
            data = try reader.readFloat()
        }
    }

    public struct RotationKeyframe: Encodable {
        public var frame: Int32
        public var quaternion: SIMD4<Float>

        init(from reader: BinaryReader) throws {
            frame = try reader.readInt()
            quaternion = try [
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat(),
                reader.readFloat()
            ]
        }
    }

    public struct PositionKeyframe: Encodable {
        public var frame: Int32
        public var px: Float
        public var py: Float
        public var pz: Float
        public var data: Int32

        init(from reader: BinaryReader) throws {
            frame = try reader.readInt()
            px = try reader.readFloat()
            py = try reader.readFloat()
            pz = try reader.readFloat()
            data = try reader.readInt()
        }
    }
}

extension RSM {
    public struct VolumeBox: Encodable {
        public var size: SIMD3<Float>
        public var position: SIMD3<Float>
        public var rotation: SIMD3<Float>
        public var flag: Int32

        init(from reader: BinaryReader, version: String) throws {
            size = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
            position = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
            rotation = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
            flag = try version >= "1.3" ? reader.readInt() : 0
        }
    }
}
