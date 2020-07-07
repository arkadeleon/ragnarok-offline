//
//  RSMDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/12.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import SGLMath

enum RSMShadingType: Int32 {

    case none = 0
    case flat = 1
    case smooth = 2
}

struct RSMFace {

    var vertidx: Vector3<UInt16>
    var tvertidx: Vector3<UInt16>
    var texid: UInt16
    var padding: UInt16
    var twoSide: Int32
    var smoothGroup: Int32
}

struct RSMPositionKeyframe {

    var frame: Int32
    var px: Float
    var py: Float
    var pz: Float
}

struct RSMRotationKeyframe {

    var frame: Int32
    var q: Vector4<Float>
}

struct RSMNode {

    var name: String
    var parentname: String

    var textures: [Int32]

    var mat3: Matrix3x3<Float>
    var offset: Vector3<Float>
    var pos: Vector3<Float>
    var rotangle: Float
    var rotaxis: Vector3<Float>
    var scale: Vector3<Float>

    var vertices: [Vector3<Float>]
    var tvertices: [Float]
    var faces: [RSMFace]
    var positionKeyframes: [RSMPositionKeyframe]
    var rotationKeyframes: [RSMRotationKeyframe]
}

struct RSMVolumeBox {

    var size: Vector3<Float>
    var position: Vector3<Float>
    var rotation: Vector3<Float>
    var flag: Int32
}

class RSMDocument: Document {

    struct Contents {
        var header: String
        var version: String
        var animLen: Int32
        var shadeType: Int32
        var alpha: Float

        var textures: [String]

        var nodes: [RSMNode]
        var mainNode: RSMNode?

        var positionKeyframes: [RSMPositionKeyframe]

        var volumeBoxes: [RSMVolumeBox]
    }

    let source: DocumentSource
    let name: String

    required init(source: DocumentSource) {
        self.source = source
        self.name = source.name
    }

    func load() -> Result<Contents, DocumentError> {
        guard let data = try? source.data() else {
            return .failure(.invalidSource)
        }

        let stream = DataStream(data: data)
        let reader = BinaryReader(stream: stream)

        do {
            let contents = try reader.readRSMContents()
            return .success(contents)
        } catch {
            return .failure(.invalidContents)
        }
    }
}

extension BinaryReader {

    fileprivate func readRSMContents() throws -> RSMDocument.Contents {
        let header = try readString(count: 4)
        guard header == "GRSM" else {
            throw DocumentError.invalidContents
        }

        let major = try readUInt8()
        let minor = try readUInt8()
        let version = "\(major).\(minor)"

        let animLen = try readInt32()
        let shadeType = try readInt32()
        let alpha = try version >= "1.4" ? Float(readUInt8()) / 255 : 1

        try skip(count: 16)

        let textureCount = try readInt32()
        var textures: [String] = []
        for _ in 0..<textureCount {
            let texture: String = try readString(count: 40)
            textures.append(texture)
        }

        let name = try readString(count: 40)
        let nodeCount = try readInt32()
        var nodes: [RSMNode] = []
        for _ in 0..<nodeCount {
            let node = try readRSMNode(version: version)
            nodes.append(node)
        }

        let mainNode = nodes.first { $0.name == name} ?? nodes.first

        var positionKeyframes: [RSMPositionKeyframe] = []
        if version < "1.5" {
            let positionKeyframeCount = try readInt32()
            for _ in 0..<positionKeyframeCount {
                let keyframe = try RSMPositionKeyframe(
                    frame: readInt32(),
                    px: readFloat32(),
                    py: readFloat32(),
                    pz: readFloat32()
                )
                positionKeyframes.append(keyframe)
            }
        }

        let volumeBoxCount = try readInt32()
        var volumeBoxes: [RSMVolumeBox] = []
        for _ in 0..<volumeBoxCount {
            let volumeBox = try RSMVolumeBox(
                size: [readFloat32(), readFloat32(), readFloat32()],
                position: [readFloat32(), readFloat32(), readFloat32()],
                rotation: [readFloat32(), readFloat32(), readFloat32()],
                flag: version >= "1.3" ? readInt32() : 0
            )
            volumeBoxes.append(volumeBox)
        }

        let contents = RSMDocument.Contents(
            header: header,
            version: version,
            animLen: animLen,
            shadeType: shadeType,
            alpha: alpha,
            textures: textures,
            nodes: nodes,
            mainNode: mainNode,
            positionKeyframes: positionKeyframes,
            volumeBoxes: volumeBoxes
        )
        return contents
    }

    fileprivate func readRSMNode(version: String) throws -> RSMNode {
        let name = try readString(count: 40)
        let parentname = try readString(count: 40)

        let textureCount = try readInt32()
        var textures: [Int32] = []
        for _ in 0..<textureCount {
            let texture = try readInt32()
            textures.append(texture)
        }

        let mat3 = try Matrix3x3(
            readFloat32(), readFloat32(), readFloat32(),
            readFloat32(), readFloat32(), readFloat32(),
            readFloat32(), readFloat32(), readFloat32()
        )
        let offset = try Vector3(readFloat32(), readFloat32(), readFloat32())
        let pos = try Vector3(readFloat32(), readFloat32(), readFloat32())
        let rotangle = try readFloat32()
        let rotaxis = try Vector3(readFloat32(), readFloat32(), readFloat32())
        let scale = try Vector3(readFloat32(), readFloat32(), readFloat32())

        let vertexCount = try readInt32()
        var vertices: [Vector3<Float>] = []
        for _ in 0..<vertexCount {
            let vertex = try Vector3(readFloat32(), readFloat32(), readFloat32())
            vertices.append(vertex)
        }

        let tvertexCount = try readInt32()
        var tvertices = Array<Float>(repeating: 0, count: Int(tvertexCount) * 6)
        for i in 0..<tvertexCount {
            let j = Int(i * 6)
            if version >= "1.2" {
                tvertices[j + 0] = try Float(readUInt8()) / 255
                tvertices[j + 1] = try Float(readUInt8()) / 255
                tvertices[j + 2] = try Float(readUInt8()) / 255
                tvertices[j + 3] = try Float(readUInt8()) / 255
            }
            tvertices[j + 4] = try readFloat32() * 0.98 + 0.01
            tvertices[j + 5] = try readFloat32() * 0.98 + 0.01
        }

        let faceCount = try readInt32()
        var faces: [RSMFace] = []
        for _ in 0..<faceCount {
            let face = try RSMFace(
                vertidx: [readUInt16(), readUInt16(), readUInt16()],
                tvertidx: [readUInt16(), readUInt16(), readUInt16()],
                texid: readUInt16(),
                padding: readUInt16(),
                twoSide: readInt32(),
                smoothGroup: version >= "1.2" ? readInt32() : 0
            )
            faces.append(face)
        }

        var positionKeyframes: [RSMPositionKeyframe] = []
        if version >= "1.5" {
            let positionKeyframeCount = try readInt32()
            for _ in 0..<positionKeyframeCount {
                let keyframe = try RSMPositionKeyframe(
                    frame: readInt32(),
                    px: readFloat32(),
                    py: readFloat32(),
                    pz: readFloat32()
                )
                positionKeyframes.append(keyframe)
            }
        }

        var rotationKeyframes: [RSMRotationKeyframe] = []
        let rotationKeyframeCount = try readInt32()
        for _ in 0..<rotationKeyframeCount {
            let keyframe = try RSMRotationKeyframe(
                frame: readInt32(),
                q: [readFloat32(), readFloat32(), readFloat32(), readFloat32()]
            )
            rotationKeyframes.append(keyframe)
        }

        let node = RSMNode(
            name: name,
            parentname: parentname,
            textures: textures,
            mat3: mat3,
            offset: offset,
            pos: pos,
            rotangle: rotangle,
            rotaxis: rotaxis,
            scale: scale,
            vertices: vertices,
            tvertices: tvertices,
            faces: faces,
            positionKeyframes: positionKeyframes,
            rotationKeyframes: rotationKeyframes
        )
        return node
    }
}
