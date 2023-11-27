//
//  Model.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/27.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Metal
import simd

struct ModelMesh {
    var vertices: [ModelVertex] = []
    var texture: MTLTexture?
}

struct ModelBoundingBox {
    var max = simd_float3(-.infinity, -.infinity, -.infinity)
    var min = simd_float3(.infinity, .infinity, .infinity)
    var offset = simd_float3()
    var range = simd_float3()
    var center = simd_float3()
}

struct Model {
    var meshes: [ModelMesh] = []
    var boundingBox: ModelBoundingBox

    init(rsm: RSM, instance: simd_float4x4, textureProvider: (String) -> MTLTexture?) {
        boundingBox = ModelBoundingBox()

        let matrix = matrix_identity_float4x4

        let wrappers = rsm.nodes.map(ModelNodeWrapper.init)
        let mainWrapper = wrappers.first { $0.node.name == rsm.mainNode?.name }

        mainWrapper?.calcBoundingBox(parentMatrix: matrix, wrappers: wrappers)

        for i in 0..<3 {
            for j in 0..<wrappers.count {
                boundingBox.max[i] = max(boundingBox.max[i], wrappers[j].box.max[i])
                boundingBox.min[i] = min(boundingBox.min[i], wrappers[j].box.min[i])
            }
            boundingBox.offset[i] = (boundingBox.max[i] + boundingBox.min[i]) / 2
            boundingBox.range[i] = (boundingBox.max[i] - boundingBox.min[i]) / 2
            boundingBox.center[i] = boundingBox.min[i] + boundingBox.range[i]
        }

        meshes = rsm.textures.map { textureName in
            ModelMesh(texture: textureProvider(textureName))
        }

        for wrapper in wrappers {
            let ms = wrapper.compile(contents: rsm, instance_matrix: instance, boundingBox: boundingBox)
            for (i, m) in ms.enumerated() {
                meshes[i].vertices.append(contentsOf: m)
            }
        }
    }

    static func createInstance(position: simd_float3, rotation: simd_float3, scale: simd_float3, width: Float, height: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix = matrix_translate(matrix, [position[0] + width, position[1], position[2] + height])
        matrix = matrix_rotate(matrix, radians(rotation[2]), [0, 0, 1])  // rotateZ
        matrix = matrix_rotate(matrix, radians(rotation[0]), [1, 0, 0])  // rotateX
        matrix = matrix_rotate(matrix, radians(rotation[1]), [0, 1, 0])  // rotateY
        matrix = matrix_scale(matrix, scale)
        return matrix
    }
}

class ModelNodeWrapper {
    let node: RSM.Node

    var box = ModelBoundingBox()
    var matrix = matrix_identity_float4x4

    init(node: RSM.Node) {
        self.node = node
    }

    func calcBoundingBox(parentMatrix: simd_float4x4, wrappers: [ModelNodeWrapper]) {
        self.matrix = parentMatrix
        self.matrix =  matrix_translate(self.matrix, node.position)

        if node.rotationKeyframes.count == 0 {
//            self.matrix = SGLMath.rotate(self.matrix, rotangle, rotaxis)
        } else {
            self.matrix = rotateQuat(self.matrix, w: node.rotationKeyframes[0].quaternion)
        }

        self.matrix = matrix_scale(self.matrix, node.scale)

        var matrix = self.matrix

        if wrappers.count > 1 {
            matrix = matrix_translate(matrix, node.offset)
        }

        matrix = matrix * simd_float4x4(node.transformationMatrix)

        for i in 0..<node.vertices.count {
            let x = node.vertices[i][0]
            let y = node.vertices[i][1]
            let z = node.vertices[i][2]

            var v = simd_float3()
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

        for wrapper in wrappers {
            if wrapper.node.parentName == node.name && node.name != node.parentName {
                wrapper.calcBoundingBox(parentMatrix: self.matrix, wrappers: wrappers)
            }
        }
    }

    func compile(contents: RSM, instance_matrix: simd_float4x4, boundingBox: ModelBoundingBox) -> [[ModelVertex]] {
        var shadeGroup = [[Float]](repeating: [], count: 32)
        var shadeGroupUsed = [Bool](repeating: false, count: 32)

        var matrix = matrix_identity_float4x4
        matrix = matrix_translate(matrix, [-boundingBox.center[0], -boundingBox.max[1], -boundingBox.center[2]])
        matrix = matrix * self.matrix

        if contents.nodes.count == 1 {
            matrix = matrix_translate(matrix, node.offset)
        }

        matrix = matrix * simd_float4x4(node.transformationMatrix)

        let modelViewMat = instance_matrix * matrix
        let normalMat = extractRotation(modelViewMat)

        let count = node.vertices.count
        var vert = [Float](repeating: 0, count: count * 3)
        for i in 0..<count {
            let x = node.vertices[i][0]
            let y = node.vertices[i][1]
            let z = node.vertices[i][2]

            vert[i * 3 + 0] = modelViewMat[0, 0] * x + modelViewMat[1, 0] * y + modelViewMat[2, 0] * z + modelViewMat[3, 0]
            vert[i * 3 + 1] = modelViewMat[0, 1] * x + modelViewMat[1, 1] * y + modelViewMat[2, 1] * z + modelViewMat[3, 1]
            vert[i * 3 + 2] = modelViewMat[0, 2] * x + modelViewMat[1, 2] * y + modelViewMat[2, 2] * z + modelViewMat[3, 2]
        }

        var face_normal = [Float](repeating: 0, count: node.faces.count * 3)

        let maxTexture = node.textureIndexes.max() ?? 0
        var mesh = [[ModelVertex]](repeating: [], count: Int(maxTexture) + 1)

        switch contents.shadeType {
        case RSM.RSMShadingType.none.rawValue:
            calcNormal_NONE(out: &face_normal)
            generate_mesh_FLAT(vert: vert, norm: face_normal, alpha: contents.alpha, mesh: &mesh)
        case RSM.RSMShadingType.flat.rawValue:
            calcNormal_FLAT(out: &face_normal, normalMat: normalMat, groupUsed: &shadeGroupUsed)
            generate_mesh_FLAT(vert: vert, norm: face_normal, alpha: contents.alpha, mesh: &mesh)
        case RSM.RSMShadingType.smooth.rawValue:
            calcNormal_FLAT(out: &face_normal, normalMat: normalMat, groupUsed: &shadeGroupUsed)
            calcNormal_SMOOTH(normal: face_normal, groupUsed: shadeGroupUsed, group: &shadeGroup)
            generate_mesh_SMOOTH(vert: vert, shadeGroup: shadeGroup, alpha: contents.alpha, mesh: &mesh)
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

    func calcNormal_FLAT(out: inout [Float], normalMat: simd_float4x4, groupUsed: inout [Bool]) {
        var j = 0
        for face in node.faces {
            let temp_vec = calcNormal(
                node.vertices[Int(face.vertidx[0])],
                node.vertices[Int(face.vertidx[1])],
                node.vertices[Int(face.vertidx[2])]
            )

            out[j + 0] = normalMat[0, 0] * temp_vec[0] + normalMat[1, 0] * temp_vec[1] + normalMat[2, 0] * temp_vec[2] + normalMat[3, 0]
            out[j + 1] = normalMat[0, 1] * temp_vec[0] + normalMat[1, 1] * temp_vec[1] + normalMat[2, 1] * temp_vec[2] + normalMat[3, 1]
            out[j + 2] = normalMat[0, 2] * temp_vec[0] + normalMat[1, 2] * temp_vec[1] + normalMat[2, 2] * temp_vec[2] + normalMat[3, 2]

            groupUsed[Int(face.smoothGroup[0])] = true

            j += 3
        }
    }

    func calcNormal_SMOOTH(normal: [Float], groupUsed: [Bool], group: inout [[Float]]) {
        for j in 0..<32 {
            if groupUsed[j] == false {
                continue
            }

            group[j] = Array<Float>(repeating: 0, count: node.vertices.count * 3)
            var norm = group[j]

            var l = 0
            for v in 0..<node.vertices.count {
                var x: Float = 0
                var y: Float = 0
                var z: Float = 0

                var k = 0
                for face in node.faces {
                    if face.smoothGroup[0] == j && (face.vertidx[0] == v || face.vertidx[1] == v || face.vertidx[2] == v) {
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

    func generate_mesh_FLAT(vert: [Float], norm: [Float], alpha: UInt8, mesh: inout [[ModelVertex]]) {
        var k = 0
        for face in node.faces {
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(node.textureIndexes[Int(face.texid)])

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j])

                let vertex = ModelVertex(
                    position: [vert[a + 0], vert[a + 1], vert[a + 2]],
                    normal: [norm[k + 0], norm[k + 1], norm[k + 2]],
                    textureCoordinate: [
                        node.tvertices[b].u * 0.98 + 0.01,
                        node.tvertices[b].v * 0.98 + 0.01
                    ],
                    alpha: Float(alpha) / 255
                )
                mesh[t].append(vertex)
            }

            k += 3
        }
    }

    func generate_mesh_SMOOTH(vert: [Float], shadeGroup: [[Float]], alpha: UInt8, mesh: inout [[ModelVertex]]) {
        for face in node.faces {
            let norm = shadeGroup[Int(face.smoothGroup[0])]
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(node.textureIndexes[Int(face.texid)])

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j])

                let vertex = ModelVertex(
                    position: [vert[a + 0], vert[a + 1], vert[a + 2]],
                    normal: [norm[a + 0], norm[a + 1], norm[a + 2]],
                    textureCoordinate: [
                        node.tvertices[b].u * 0.98 + 0.01,
                        node.tvertices[b].v * 0.98 + 0.01
                    ],
                    alpha: Float(alpha) / 255
                )
                mesh[t].append(vertex)
            }
        }
    }
}
