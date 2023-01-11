//
//  RSMDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/12.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

enum RSMShadingType: Int32 {

    case none = 0
    case flat = 1
    case smooth = 2
}

struct RSMFace {

    var vertidx: simd_ushort3
    var tvertidx: simd_ushort3
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
    var q: simd_float4
}

struct RSMNode {

    var name: String
    var parentname: String

    var textures: [Int32]

    var mat3: simd_float3x3
    var offset: simd_float3
    var pos: simd_float3
    var rotangle: Float
    var rotaxis: simd_float3
    var scale: simd_float3

    var vertices: [simd_float3]
    var tvertices: [Float]
    var faces: [RSMFace]
    var positionKeyframes: [RSMPositionKeyframe]
    var rotationKeyframes: [RSMRotationKeyframe]
}

struct RSMVolumeBox {

    var size: simd_float3
    var position: simd_float3
    var rotation: simd_float3
    var flag: Int32
}

struct RSMDocument: Document {

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

    init(from stream: Stream) throws {
        let reader = StreamReader(stream: stream)

        header = try reader.readString(count: 4)
        guard header == "GRSM" else {
            throw DocumentError.invalidContents
        }

        let major = try reader.readUInt8()
        let minor = try reader.readUInt8()
        version = "\(major).\(minor)"

        animLen = try reader.readInt32()
        shadeType = try reader.readInt32()
        alpha = try version >= "1.4" ? Float(reader.readUInt8()) / 255 : 1

        try reader.skip(count: 16)

        let textureCount = try reader.readInt32()
        var textures: [String] = []
        for _ in 0..<textureCount {
            let texture: String = try reader.readString(count: 40, encoding: .koreanEUC)
            textures.append(texture)
        }
        self.textures = textures

        let name = try reader.readString(count: 40)
        let nodeCount = try reader.readInt32()
        var nodes: [RSMNode] = []
        for _ in 0..<nodeCount {
            let node = try reader.readRSMNode(version: version)
            nodes.append(node)
        }
        self.nodes = nodes

        mainNode = nodes.first { $0.name == name} ?? nodes.first

        var positionKeyframes: [RSMPositionKeyframe] = []
        if version < "1.5" {
            let positionKeyframeCount = try reader.readInt32()
            for _ in 0..<positionKeyframeCount {
                let keyframe = try RSMPositionKeyframe(
                    frame: reader.readInt32(),
                    px: reader.readFloat32(),
                    py: reader.readFloat32(),
                    pz: reader.readFloat32()
                )
                positionKeyframes.append(keyframe)
            }
        }
        self.positionKeyframes = positionKeyframes

        let volumeBoxCount = try reader.readInt32()
        var volumeBoxes: [RSMVolumeBox] = []
        for _ in 0..<volumeBoxCount {
            let volumeBox = try RSMVolumeBox(
                size: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32()],
                position: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32()],
                rotation: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32()],
                flag: version >= "1.3" ? reader.readInt32() : 0
            )
            volumeBoxes.append(volumeBox)
        }
        self.volumeBoxes = volumeBoxes
    }
}

extension StreamReader {

    fileprivate func readRSMNode(version: String) throws -> RSMNode {
        let name = try readString(count: 40)
        let parentname = try readString(count: 40)

        let textureCount = try readInt32()
        var textures: [Int32] = []
        for _ in 0..<textureCount {
            let texture = try readInt32()
            textures.append(texture)
        }

        let mat3 = try simd_float3x3(
            [readFloat32(), readFloat32(), readFloat32()],
            [readFloat32(), readFloat32(), readFloat32()],
            [readFloat32(), readFloat32(), readFloat32()]
        )
        let offset: simd_float3 = try [readFloat32(), readFloat32(), readFloat32()]
        let pos: simd_float3 = try [readFloat32(), readFloat32(), readFloat32()]
        let rotangle = try readFloat32()
        let rotaxis: simd_float3 = try [readFloat32(), readFloat32(), readFloat32()]
        let scale: simd_float3 = try [readFloat32(), readFloat32(), readFloat32()]

        let vertexCount = try readInt32()
        var vertices: [simd_float3] = []
        for _ in 0..<vertexCount {
            let vertex: simd_float3 = try [readFloat32(), readFloat32(), readFloat32()]
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
