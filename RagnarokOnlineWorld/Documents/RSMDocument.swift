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

struct RSMBoundingBox {

    var max = Vector3<Float>(-.infinity, -.infinity, -.infinity)
    var min = Vector3<Float>(.infinity, .infinity, .infinity)
    var offset = Vector3<Float>()
    var range = Vector3<Float>()
    var center = Vector3<Float>()
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

struct RSMVolumeBox {

    var size: Vector3<Float>
    var position: Vector3<Float>
    var rotation: Vector3<Float>
    var flag: Int32
}

struct RSMModel {

    var position: Vector3<Float>
    var rotation: Vector3<Float>
    var scale: Vector3<Float>
    var filename: String
}

class RSMNode: NSObject {

    weak var main: RSMDocument?
    var isOnly = false

    var name = ""
    var parentname = ""

    var textures: [Int32] = []

    var mat3 = Matrix3x3<Float>()
    var offset = Vector3<Float>()
    var pos = Vector3<Float>()
    var rotangle: Float = 0
    var rotaxis = Vector3<Float>()
    var scale = Vector3<Float>()

    var vertices: [Vector3<Float>] = []
    var tvertices: [Float] = []
    var faces: [RSMFace] = []
    var positionKeyframes: [RSMPositionKeyframe] = []
    var rotationKeyframes: [RSMRotationKeyframe] = []

    var box = RSMBoundingBox()
    var matrix = Matrix4x4<Float>()

    func calcBoundingBox(_ _matrix: Matrix4x4<Float>) {
        self.matrix = _matrix
        self.matrix =  SGLMath.translate(self.matrix, pos)

        if rotationKeyframes.count == 0 {
//            self.matrix = SGLMath.rotate(self.matrix, rotangle, rotaxis)
        } else {
            self.matrix = SGLMath.rotateQuat(self.matrix, w: rotationKeyframes[0].q)
        }

        self.matrix = SGLMath.scale(self.matrix, scale)

        var matrix = self.matrix

        if !isOnly {
            matrix = SGLMath.translate(matrix, offset)
        }

        matrix = matrix * Matrix4x4(mat3)

        for i in 0..<vertices.count {
            let x = vertices[i][0]
            let y = vertices[i][1]
            let z = vertices[i][2]

            var v = Vector3<Float>()
            v[0] = matrix[0, 0] * x + matrix[1, 0] * y + matrix[2, 0] * z + matrix[3, 0]
            v[1] = matrix[0, 1] * x + matrix[1, 1] * y + matrix[2, 1] * z + matrix[3, 1]
            v[2] = matrix[0, 2] * x + matrix[1, 2] * y + matrix[2, 2] * z + matrix[3, 2]

            for j in 0..<3 {
                box.min[j] = min(v[j], box.min[j])
                box.max[j] = max(v[j], box.max[j])
            }
        }

        for i in 0..<3 {
            box.offset[i] = (box.max[i] + box.min[i]) / 2
            box.range[i] = (box.max[i] - box.min[i]) / 2
            box.center[i] = box.min[i] + box.range[i]
        }

        for node in main?.nodes ?? [] {
            if node.parentname == name && name != parentname {
                node.calcBoundingBox(self.matrix)
            }
        }
    }

    func compile(instance_matrix: Matrix4x4<Float>) -> [[Float]] {
        var shadeGroup = [[Float]](repeating: [], count: 32)
        var shadeGroupUsed = [Bool](repeating: false, count: 32)

        var matrix = Matrix4x4<Float>()
        matrix = SGLMath.translate(matrix, [-main!.box.center[0], -main!.box.max[1], -main!.box.center[2]])
        matrix = matrix * self.matrix

        if isOnly {
            matrix = SGLMath.translate(matrix, offset)
        }

        matrix = matrix * Matrix4x4(mat3)

        let modelViewMat = instance_matrix * matrix
        let normalMat = SGLMath.extractRotation(modelViewMat)

        let count = vertices.count
        var vert = [Float](repeating: 0, count: count * 3)
        for i in 0..<count {
            let x = vertices[i][0]
            let y = vertices[i][1]
            let z = vertices[i][2]

            vert[i * 3 + 0] = modelViewMat[0, 0] * x + modelViewMat[1, 0] * y + modelViewMat[2, 0] * z + modelViewMat[3, 0]
            vert[i * 3 + 1] = modelViewMat[0, 1] * x + modelViewMat[1, 1] * y + modelViewMat[2, 1] * z + modelViewMat[3, 1]
            vert[i * 3 + 2] = modelViewMat[0, 2] * x + modelViewMat[1, 2] * y + modelViewMat[2, 2] * z + modelViewMat[3, 2]
        }

        var face_normal = [Float](repeating: 0, count: faces.count * 3)

        let maxTexture = textures.max() ?? 0
        var mesh_size = [Int](repeating: 0, count: Int(maxTexture) + 1)
        var mesh = [[Float]](repeating: [], count: Int(maxTexture) + 1)

        for face in faces {
            let texid = face.texid
            let texture = textures[Int(texid)]
            mesh_size[Int(texture)] += 1
        }

        for texture in textures {
            mesh[Int(texture)] = [Float](repeating: 0, count: mesh_size[Int(texture)] * 9 * 3)
        }

        switch main!.shadeType {
        case RSMShadingType.none.rawValue:
            calcNormal_NONE(out: &face_normal)
            generate_mesh_FLAT(vert: vert, norm: face_normal, mesh: &mesh)
        case RSMShadingType.flat.rawValue:
            calcNormal_FLAT(out: &face_normal, normalMat: normalMat, groupUsed: &shadeGroupUsed)
            generate_mesh_FLAT(vert: vert, norm: face_normal, mesh: &mesh)
        case RSMShadingType.smooth.rawValue:
            calcNormal_FLAT(out: &face_normal, normalMat: normalMat, groupUsed: &shadeGroupUsed)
            calcNormal_SMOOTH(normal: face_normal, groupUsed: shadeGroupUsed, group: &shadeGroup)
            generate_mesh_SMOOTH(vert: vert, shadeGroup: shadeGroup, mesh: &mesh)
        default:
            break
        }

        return mesh
    }

    func calcNormal_NONE(out: inout [Float]) {
        var i = 1
        while i < out.count {
            out[i] = -1
            i += 3
        }
    }

    func calcNormal_FLAT(out: inout [Float], normalMat: Matrix4x4<Float>, groupUsed: inout [Bool]) {
        var j = 0
        for face in faces {
            let temp_vec = SGLMath.calcNormal(
                vertices[Int(face.vertidx[0])],
                vertices[Int(face.vertidx[1])],
                vertices[Int(face.vertidx[2])]
            )

            out[j + 0] = normalMat[0, 0] * temp_vec[0] + normalMat[1, 0] * temp_vec[1] + normalMat[2, 0] * temp_vec[2] + normalMat[3, 0]
            out[j + 1] = normalMat[0, 1] * temp_vec[0] + normalMat[1, 1] * temp_vec[1] + normalMat[2, 1] * temp_vec[2] + normalMat[3, 1]
            out[j + 2] = normalMat[0, 2] * temp_vec[0] + normalMat[1, 2] * temp_vec[1] + normalMat[2, 2] * temp_vec[2] + normalMat[3, 2]

            groupUsed[Int(face.smoothGroup)] = true

            j += 3
        }
    }

    func calcNormal_SMOOTH(normal: [Float], groupUsed: [Bool], group: inout [[Float]]) {
        for j in 0..<32 {
            if groupUsed[j] == false {
                continue
            }

            group[j] = Array<Float>(repeating: 0, count: vertices.count * 3)
            var norm = group[j]

            var l = 0
            for v in 0..<vertices.count {
                var x: Float = 0
                var y: Float = 0
                var z: Float = 0

                var k = 0
                for face in faces {
                    if face.smoothGroup == j && (face.vertidx[0] == v || face.vertidx[1] == v || face.vertidx[2] == v) {
                        x += normal[k]
                        y += normal[k + 1]
                        z += normal[k + 2]
                    }

                    k += 3
                }

                let len = 1 / sqrtf(x * x + y * y + z * z)
                norm[l] = x * len
                norm[l + 1] = y * len
                norm[l + 2] = z * len

                l += 3
            }

            group[j] = norm
        }
    }

    func generate_mesh_FLAT(vert: [Float], norm: [Float], mesh: inout [[Float]]) {
        let maxTexture = Int(textures.max() ?? 0)
        var offset = Array(repeating: 0, count: maxTexture + 1)

        var o = 0
        var k = 0
        for face in faces {
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(textures[Int(face.texid)])
            var out = mesh[t]
            o = offset[t]

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j]) * 6

                out[o + 0] = vert[a + 0]
                out[o + 1] = vert[a + 1]
                out[o + 2] = vert[a + 2]
                out[o + 3] = norm[k + 0]
                out[o + 4] = norm[k + 1]
                out[o + 5] = norm[k + 2]
                out[o + 6] = tvertices[b + 4]
                out[o + 7] = tvertices[b + 5]
                out[o + 8] = main!.alpha

                o += 9
            }

            mesh[t] = out

            offset[t] = o

            k += 3
        }
    }

    func generate_mesh_SMOOTH(vert: [Float], shadeGroup: [[Float]], mesh: inout [[Float]]) {
        let maxTexture = Int(textures.max() ?? 0)
        var offset = Array(repeating: 0, count: maxTexture + 1)

        var o = 0
        for face in faces {
            let norm = shadeGroup[Int(face.smoothGroup)]
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(textures[Int(face.texid)])
            var out = mesh[t]
            o = offset[t]

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j]) * 6

                out[o + 0] = vert[a + 0]
                out[o + 1] = vert[a + 1]
                out[o + 2] = vert[a + 2]
                out[o + 3] = norm[a + 0]
                out[o + 4] = norm[a + 1]
                out[o + 5] = norm[a + 2]
                out[o + 6] = tvertices[b + 4]
                out[o + 7] = tvertices[b + 5]
                out[o + 8] = main!.alpha

                o += 9
            }

            mesh[t] = out

            offset[t] = o
        }
    }
}

class RSMDocument: Document {

    private var reader: BinaryReader!

    private(set) var header = ""
    private(set) var version = ""
    private(set) var animLen: Int32 = 0
    private(set) var shadeType: Int32 = 0
    private(set) var alpha: Float = 1

    private(set) var textures: [String] = []

    private(set) var nodes: [RSMNode] = []
    private(set) var mainNode: RSMNode?

    private(set) var positionKeyframes: [RSMPositionKeyframe] = []

    private(set) var volumeBoxes: [RSMVolumeBox] = []

    private(set) var instances: [Matrix4x4<Float>] = []
    private(set) var box = RSMBoundingBox()

    override func load(from contents: Data) throws {
        let stream = DataStream(data: contents)
        reader = BinaryReader(stream: stream)

        header = try reader.readString(count: 4)
        guard header == "GRSM" else {
            throw StreamError.invalidContents
        }

        let major = try reader.readUInt8()
        let minor = try reader.readUInt8()
        version = "\(major).\(minor)"

        animLen = try reader.readInt32()
        shadeType = try reader.readInt32()
        alpha = try version >= "1.4" ? Float(reader.readUInt8()) / 255 : 1

        try reader.skip(count: 16)

        let textureCount = try reader.readInt32()
        for _ in 0..<textureCount {
            var texture: String = try reader.readString(count: 40)
            if let index = texture.firstIndex(of: "\0") {
                texture = String(texture.prefix(upTo: index))
            }
            textures.append(texture)
        }

        let name = try reader.readString(count: 40)
        let nodeCount = try reader.readInt32()
        for _ in 0..<nodeCount {
            let node = try readNode(isOnly: nodeCount == 1)
            nodes.append(node)
        }

        mainNode = nodes.first { $0.name == name} ?? nodes.first

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

        let volumeBoxCount = try reader.readInt32()
        for _ in 0..<volumeBoxCount {
            let volumeBox = try RSMVolumeBox(
                size: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32()],
                position: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32()],
                rotation: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32()],
                flag: version >= "1.3" ? reader.readInt32() : 0
            )
            volumeBoxes.append(volumeBox)
        }

        calcBoundingBox()

        reader = nil
    }

    func createInstance(model: RSMModel, width: Float, height: Float) {
        var matrix = Matrix4x4<Float>()
        matrix = SGLMath.translate(matrix, [model.position[0] + width, model.position[1], model.position[2] + height])
        matrix = SGLMath.rotate(matrix, radians(model.rotation[2]), [0, 0, 1])  // rotateZ
        matrix = SGLMath.rotate(matrix, radians(model.rotation[0]), [1, 0, 0])  // rotateX
        matrix = SGLMath.rotate(matrix, radians(model.rotation[1]), [0, 1, 0])  // rotateY
        matrix = SGLMath.scale(matrix, model.scale)
        instances.append(matrix)
    }

    func compile() -> [[[Float]]] {
        var meshes = [[[Float]]]()
        for node in nodes {
            for instance in instances {
                meshes.append(node.compile(instance_matrix: instance))
            }
        }
        return meshes
    }

    private func readNode(isOnly: Bool) throws -> RSMNode {
        let node = RSMNode()

        node.main = self
        node.isOnly = isOnly

        node.name = try reader.readString(count: 40)
        node.parentname = try reader.readString(count: 40)

        let textureCount = try reader.readInt32()
        for _ in 0..<textureCount {
            let texture = try reader.readInt32()
            node.textures.append(texture)
        }

        node.mat3 = try Matrix3x3(
            reader.readFloat32(), reader.readFloat32(), reader.readFloat32(),
            reader.readFloat32(), reader.readFloat32(), reader.readFloat32(),
            reader.readFloat32(), reader.readFloat32(), reader.readFloat32()
        )
        node.offset = try Vector3(reader.readFloat32(), reader.readFloat32(), reader.readFloat32())
        node.pos = try Vector3(reader.readFloat32(), reader.readFloat32(), reader.readFloat32())
        node.rotangle = try reader.readFloat32()
        node.rotaxis = try Vector3(reader.readFloat32(), reader.readFloat32(), reader.readFloat32())
        node.scale = try Vector3(reader.readFloat32(), reader.readFloat32(), reader.readFloat32())

        let vertexCount = try reader.readInt32()
        for _ in 0..<vertexCount {
            let vertex = try Vector3(reader.readFloat32(), reader.readFloat32(), reader.readFloat32())
            node.vertices.append(vertex)
        }

        let tvertexCount = try reader.readInt32()
        var tvertices = Array<Float>(repeating: 0, count: Int(tvertexCount) * 6)
        for i in 0..<tvertexCount {
            let j = Int(i * 6)
            if version >= "1.2" {
                tvertices[j + 0] = try Float(reader.readUInt8()) / 255
                tvertices[j + 1] = try Float(reader.readUInt8()) / 255
                tvertices[j + 2] = try Float(reader.readUInt8()) / 255
                tvertices[j + 3] = try Float(reader.readUInt8()) / 255
            }
            tvertices[j + 4] = try reader.readFloat32() * 0.98 + 0.01
            tvertices[j + 5] = try reader.readFloat32() * 0.98 + 0.01
        }
        node.tvertices = tvertices

        let faceCount = try reader.readInt32()
        for _ in 0..<faceCount {
            let face = try RSMFace(
                vertidx: [reader.readUInt16(), reader.readUInt16(), reader.readUInt16()],
                tvertidx: [reader.readUInt16(), reader.readUInt16(), reader.readUInt16()],
                texid: reader.readUInt16(),
                padding: reader.readUInt16(),
                twoSide: reader.readInt32(),
                smoothGroup: version >= "1.2" ? reader.readInt32() : 0
            )
            node.faces.append(face)
        }

        if version >= "1.5" {
            let positionKeyframeCount = try reader.readInt32()
            for _ in 0..<positionKeyframeCount {
                let keyframe = try RSMPositionKeyframe(
                    frame: reader.readInt32(),
                    px: reader.readFloat32(),
                    py: reader.readFloat32(),
                    pz: reader.readFloat32()
                )
                node.positionKeyframes.append(keyframe)
            }
        }

        let rotationKeyframeCount = try reader.readInt32()
        for _ in 0..<rotationKeyframeCount {
            let keyframe = try RSMRotationKeyframe(
                frame: reader.readInt32(),
                q: [reader.readFloat32(), reader.readFloat32(), reader.readFloat32(), reader.readFloat32()]
            )
            node.rotationKeyframes.append(keyframe)
        }

        return node
    }

    private func calcBoundingBox() {
        let matrix = Matrix4x4<Float>()
        mainNode?.calcBoundingBox(matrix)

        for i in 0..<3 {
            for j in 0..<nodes.count {
                box.max[i] = max(box.max[i], nodes[j].box.max[i])
                box.min[i] = min(box.min[i], nodes[j].box.min[i])
            }
            box.offset[i] = (box.max[i] + box.min[i]) / 2
            box.range[i] = (box.max[i] - box.min[i]) / 2
            box.center[i] = box.min[i] + box.range[i]
        }
    }
}
