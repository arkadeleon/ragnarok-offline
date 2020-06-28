//
//  RSMDocument+Compile.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/28.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import SGLMath

extension RSMNode {

    func compile(instance_matrix: Matrix4x4<Float>) -> [[ModelVertex]] {
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
        var mesh = [[ModelVertex]](repeating: [], count: Int(maxTexture) + 1)

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

    func generate_mesh_FLAT(vert: [Float], norm: [Float], mesh: inout [[ModelVertex]]) {
        var k = 0
        for face in faces {
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(textures[Int(face.texid)])

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j]) * 6

                let vertex = ModelVertex(
                    position: [vert[a + 0], vert[a + 1], vert[a + 2]],
                    normal: [norm[k + 0], norm[k + 1], norm[k + 2]],
                    textureCoordinate: [tvertices[b + 4], tvertices[b + 5]],
                    alpha: main!.alpha
                )
                mesh[t].append(vertex)
            }

            k += 3
        }
    }

    func generate_mesh_SMOOTH(vert: [Float], shadeGroup: [[Float]], mesh: inout [[ModelVertex]]) {
        for face in faces {
            let norm = shadeGroup[Int(face.smoothGroup)]
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(textures[Int(face.texid)])

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j]) * 6

                let vertex = ModelVertex(
                    position: [vert[a + 0], vert[a + 1], vert[a + 2]],
                    normal: [norm[a + 0], norm[a + 1], norm[a + 2]],
                    textureCoordinate: [tvertices[b + 4], tvertices[b + 5]],
                    alpha: main!.alpha
                )
                mesh[t].append(vertex)
            }
        }
    }
}

extension RSMDocument {

    func compile() -> [[[ModelVertex]]] {
        var meshes = [[[ModelVertex]]]()
        for node in nodes {
            for instance in instances {
                meshes.append(node.compile(instance_matrix: instance))
            }
        }
        return meshes
    }
}
