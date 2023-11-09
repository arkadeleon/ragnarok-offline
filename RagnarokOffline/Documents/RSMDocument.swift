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

    init(from reader: BinaryReader, version: String) throws {
        vertidx = try [reader.readInt(), reader.readInt(), reader.readInt()]
        tvertidx = try [reader.readInt(), reader.readInt(), reader.readInt()]
        texid = try reader.readInt()
        padding = try reader.readInt()
        twoSide = try reader.readInt()
        smoothGroup = try version >= "1.2" ? reader.readInt() : 0
    }
}

struct RSMPositionKeyframe {

    var frame: Int32
    var px: Float
    var py: Float
    var pz: Float

    init(from reader: BinaryReader) throws {
        frame = try reader.readInt()
        px = try reader.readFloat()
        py = try reader.readFloat()
        pz = try reader.readFloat()
    }
}

struct RSMRotationKeyframe {

    var frame: Int32
    var q: simd_float4

    init(from reader: BinaryReader) throws {
        frame = try reader.readInt()
        q = try [reader.readFloat(), reader.readFloat(), reader.readFloat(), reader.readFloat()]
    }
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

    init(from reader: BinaryReader, version: String) throws {
        name = try reader.readString(40, encoding: .ascii)
        parentname = try reader.readString(40, encoding: .ascii)

        let textureCount: Int32 = try reader.readInt()
        textures = []
        for _ in 0..<textureCount {
            let texture: Int32 = try reader.readInt()
            textures.append(texture)
        }

        mat3 = try simd_float3x3(
            [reader.readFloat(), reader.readFloat(), reader.readFloat()],
            [reader.readFloat(), reader.readFloat(), reader.readFloat()],
            [reader.readFloat(), reader.readFloat(), reader.readFloat()]
        )
        offset = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
        pos = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
        rotangle = try reader.readFloat()
        rotaxis = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
        scale = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]

        let vertexCount: Int32 = try reader.readInt()
        vertices = []
        for _ in 0..<vertexCount {
            let vertex: simd_float3 = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
            vertices.append(vertex)
        }

        let tvertexCount: Int32 = try reader.readInt()
        tvertices = Array<Float>(repeating: 0, count: Int(tvertexCount) * 6)
        for i in 0..<tvertexCount {
            let j = Int(i * 6)
            if version >= "1.2" {
                tvertices[j + 0] = try Float(reader.readInt() as UInt8) / 255
                tvertices[j + 1] = try Float(reader.readInt() as UInt8) / 255
                tvertices[j + 2] = try Float(reader.readInt() as UInt8) / 255
                tvertices[j + 3] = try Float(reader.readInt() as UInt8) / 255
            }
            tvertices[j + 4] = try reader.readFloat() * 0.98 + 0.01
            tvertices[j + 5] = try reader.readFloat() * 0.98 + 0.01
        }

        let faceCount: Int32 = try reader.readInt()
        faces = []
        for _ in 0..<faceCount {
            let face = try RSMFace(from: reader, version: version)
            faces.append(face)
        }

        positionKeyframes = []
        if version >= "1.5" {
            let positionKeyframeCount: Int32 = try reader.readInt()
            for _ in 0..<positionKeyframeCount {
                let keyframe = try RSMPositionKeyframe(from: reader)
                positionKeyframes.append(keyframe)
            }
        }

        rotationKeyframes = []
        let rotationKeyframeCount: Int32 = try reader.readInt()
        for _ in 0..<rotationKeyframeCount {
            let keyframe = try RSMRotationKeyframe(from: reader)
            rotationKeyframes.append(keyframe)
        }
    }
}

struct RSMVolumeBox {

    var size: simd_float3
    var position: simd_float3
    var rotation: simd_float3
    var flag: Int32

    init(from reader: BinaryReader, version: String) throws {
        size = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
        position = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
        rotation = try [reader.readFloat(), reader.readFloat(), reader.readFloat()]
        flag = try version >= "1.3" ? reader.readInt() : 0
    }
}

struct RSMDocument {

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

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        defer {
            stream.close()
        }

        let reader = BinaryReader(stream: stream)

        header = try reader.readString(4, encoding: .ascii)
        guard header == "GRSM" else {
            throw DocumentError.invalidContents
        }

        let major: UInt8 = try reader.readInt()
        let minor: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        animLen = try reader.readInt()
        shadeType = try reader.readInt()
        alpha = try version >= "1.4" ? Float(reader.readInt() as UInt8) / 255 : 1

        _ = try reader.readBytes(16)

        let textureCount: Int32 = try reader.readInt()
        textures = []
        for _ in 0..<textureCount {
            let texture = try reader.readString(40, encoding: .koreanEUC)
            textures.append(texture)
        }

        let name = try reader.readString(40, encoding: .ascii)
        let nodeCount: Int32 = try reader.readInt()
        nodes = []
        for _ in 0..<nodeCount {
            let node = try RSMNode(from: reader, version: version)
            nodes.append(node)
        }

        mainNode = nodes.first { $0.name == name} ?? nodes.first

        positionKeyframes = []
        if version < "1.5" {
            let positionKeyframeCount: Int32 = try reader.readInt()
            for _ in 0..<positionKeyframeCount {
                let keyframe = try RSMPositionKeyframe(from: reader)
                positionKeyframes.append(keyframe)
            }
        }

        let volumeBoxCount: Int32 = try reader.readInt()
        volumeBoxes = []
        for _ in 0..<volumeBoxCount {
            let volumeBox = try RSMVolumeBox(from: reader, version: version)
            volumeBoxes.append(volumeBox)
        }
    }
}
