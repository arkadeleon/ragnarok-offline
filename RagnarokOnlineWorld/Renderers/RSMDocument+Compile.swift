//
//  RSMDocument+Compile.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/28.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import SGLMath

struct RSMModel {

    var position: Vector3<Float>
    var rotation: Vector3<Float>
    var scale: Vector3<Float>
    var filename: String
}

extension RSMNodeBoundingBoxWrapper {

    func compile(contents: RSMDocument.Contents, instance_matrix: Matrix4x4<Float>, boundingBox: RSMBoundingBox) -> [[ModelVertex]] {
        var shadeGroup = [[Float]](repeating: [], count: 32)
        var shadeGroupUsed = [Bool](repeating: false, count: 32)

        var matrix = Matrix4x4<Float>()
        matrix = SGLMath.translate(matrix, [-boundingBox.center[0], -boundingBox.max[1], -boundingBox.center[2]])
        matrix = matrix * self.matrix

        if contents.nodes.count == 1 {
            matrix = SGLMath.translate(matrix, node.offset)
        }

        matrix = matrix * Matrix4x4(node.mat3)

        let modelViewMat = instance_matrix * matrix
        let normalMat = SGLMath.extractRotation(modelViewMat)

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

        let maxTexture = node.textures.max() ?? 0
        var mesh = [[ModelVertex]](repeating: [], count: Int(maxTexture) + 1)

        switch contents.shadeType {
        case RSMShadingType.none.rawValue:
            calcNormal_NONE(out: &face_normal)
            generate_mesh_FLAT(vert: vert, norm: face_normal, alpha: contents.alpha, mesh: &mesh)
        case RSMShadingType.flat.rawValue:
            calcNormal_FLAT(out: &face_normal, normalMat: normalMat, groupUsed: &shadeGroupUsed)
            generate_mesh_FLAT(vert: vert, norm: face_normal, alpha: contents.alpha, mesh: &mesh)
        case RSMShadingType.smooth.rawValue:
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

    func calcNormal_FLAT(out: inout [Float], normalMat: Matrix4x4<Float>, groupUsed: inout [Bool]) {
        var j = 0
        for face in node.faces {
            let temp_vec = SGLMath.calcNormal(
                node.vertices[Int(face.vertidx[0])],
                node.vertices[Int(face.vertidx[1])],
                node.vertices[Int(face.vertidx[2])]
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

            group[j] = Array<Float>(repeating: 0, count: node.vertices.count * 3)
            var norm = group[j]

            var l = 0
            for v in 0..<node.vertices.count {
                var x: Float = 0
                var y: Float = 0
                var z: Float = 0

                var k = 0
                for face in node.faces {
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

    func generate_mesh_FLAT(vert: [Float], norm: [Float], alpha: Float, mesh: inout [[ModelVertex]]) {
        var k = 0
        for face in node.faces {
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(node.textures[Int(face.texid)])

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j]) * 6

                let vertex = ModelVertex(
                    position: [vert[a + 0], vert[a + 1], vert[a + 2]],
                    normal: [norm[k + 0], norm[k + 1], norm[k + 2]],
                    textureCoordinate: [node.tvertices[b + 4], node.tvertices[b + 5]],
                    alpha: alpha
                )
                mesh[t].append(vertex)
            }

            k += 3
        }
    }

    func generate_mesh_SMOOTH(vert: [Float], shadeGroup: [[Float]], alpha: Float, mesh: inout [[ModelVertex]]) {
        for face in node.faces {
            let norm = shadeGroup[Int(face.smoothGroup)]
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(node.textures[Int(face.texid)])

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j]) * 6

                let vertex = ModelVertex(
                    position: [vert[a + 0], vert[a + 1], vert[a + 2]],
                    normal: [norm[a + 0], norm[a + 1], norm[a + 2]],
                    textureCoordinate: [node.tvertices[b + 4], node.tvertices[b + 5]],
                    alpha: alpha
                )
                mesh[t].append(vertex)
            }
        }
    }
}

extension RSMDocument.Contents {

    func compile(instances: [Matrix4x4<Float>], wrappers: [RSMNodeBoundingBoxWrapper], boundingBox: RSMBoundingBox) -> [[[ModelVertex]]] {
        var meshes = [[[ModelVertex]]]()
        for wrapper in wrappers {
            for instance in instances {
                let mesh = wrapper.compile(contents: self, instance_matrix: instance, boundingBox: boundingBox)
                meshes.append(mesh)
            }
        }
        return meshes
    }

    func createInstance(model: RSMModel, width: Float, height: Float) -> Matrix4x4<Float> {
        var matrix = Matrix4x4<Float>()
        matrix = SGLMath.translate(matrix, [model.position[0] + width, model.position[1], model.position[2] + height])
        matrix = SGLMath.rotate(matrix, radians(model.rotation[2]), [0, 0, 1])  // rotateZ
        matrix = SGLMath.rotate(matrix, radians(model.rotation[0]), [1, 0, 0])  // rotateX
        matrix = SGLMath.rotate(matrix, radians(model.rotation[1]), [0, 1, 0])  // rotateY
        matrix = SGLMath.scale(matrix, model.scale)
        return matrix
    }
}
