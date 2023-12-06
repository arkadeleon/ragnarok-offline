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
    var min: simd_float3 = [.infinity, .infinity, .infinity]
    var max: simd_float3 = [-.infinity, -.infinity, -.infinity]

    var range: simd_float3 {
        (max - min) / 2
    }

    var center: simd_float3 {
        (min + max) / 2
    }
}

struct Model {
    var meshes: [ModelMesh] = []
    var boundingBox: ModelBoundingBox

    init(rsm: RSM, instance: simd_float4x4, textureProvider: (String) -> MTLTexture?) {
        boundingBox = ModelBoundingBox()

        let wrappers = rsm.nodes.map(ModelNodeWrapper.init)
        let rootWrapper = wrappers.first { $0.node.name == rsm.rootNodes.first }

        for parent in wrappers {
            for child in wrappers {
                if child.node.parentName == parent.node.name && parent.node.name != parent.node.parentName {
                    parent.addChild(child)
                }
            }
        }

        rootWrapper?.calcBoundingBox(wrappers: wrappers)

        for i in 0..<3 {
            for wrapper in wrappers {
                boundingBox.max[i] = max(boundingBox.max[i], wrapper.box.max[i])
                boundingBox.min[i] = min(boundingBox.min[i], wrapper.box.min[i])
            }
        }

        meshes = rsm.textures.map { textureName in
            ModelMesh(texture: textureProvider(textureName))
        }

        for wrapper in wrappers {
            let ms = wrapper.compile(rsm: rsm, instance_matrix: instance, boundingBox: boundingBox)
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

    weak var parent: ModelNodeWrapper?
    var children: [ModelNodeWrapper] = []

    var transformForChildren = matrix_identity_float4x4

    var worldTransformForChildren: simd_float4x4 {
        if let parent {
            return parent.worldTransformForChildren * transformForChildren
        } else {
            return transformForChildren
        }
    }

    var transform = matrix_identity_float4x4

    var worldTransform: simd_float4x4 {
        if let parent {
            return parent.worldTransformForChildren * transform
        } else {
            return transform
        }
    }

    init(node: RSM.Node) {
        self.node = node
    }

    func addChild(_ child: ModelNodeWrapper) {
        children.append(child)
        child.parent = self
    }

    func calcBoundingBox(wrappers: [ModelNodeWrapper]) {
        transformForChildren = matrix_identity_float4x4
        transformForChildren = matrix_translate(transformForChildren, node.position)

        if node.rotationKeyframes.count == 0 {
//            transformForChildren = SGLMath.rotate(transformForChildren, rotangle, rotaxis)
        } else {
            transformForChildren = rotateQuat(transformForChildren, w: node.rotationKeyframes[0].quaternion)
        }

        transformForChildren = matrix_scale(transformForChildren, node.scale)

        transform = transformForChildren

//        if wrappers.count > 1 {
            transform = matrix_translate(transform, node.offset)
//        }

        transform = transform * simd_float4x4(node.transformationMatrix)

        let matrix = worldTransform
        for vertex in node.vertices {
            let vertex = matrix * simd_float4(vertex, 1)

            for j in 0..<3 {
                box.min[j] = min(vertex[j], box.min[j])
                box.max[j] = max(vertex[j], box.max[j])
            }
        }

        for child in children {
            child.calcBoundingBox(wrappers: wrappers)
        }
    }

    func compile(rsm: RSM, instance_matrix: simd_float4x4, boundingBox: ModelBoundingBox) -> [[ModelVertex]] {
        var shadeGroup = [[Float]](repeating: [], count: 32)
        var shadeGroupUsed = [Bool](repeating: false, count: 32)

        var matrix = matrix_identity_float4x4
        matrix = matrix_translate(matrix, [-boundingBox.center[0], -boundingBox.max[1], -boundingBox.center[2]])
        matrix = matrix * worldTransform

//        if rsm.nodes.count == 1 {
//            matrix = matrix_translate(matrix, node.offset)
//        }
//
//        matrix = matrix * simd_float4x4(node.transformationMatrix)

        // modelMatrix = instance * translate * worldTransform
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

        switch rsm.shadeType {
        case RSM.RSMShadingType.none.rawValue:
            calcNormal_NONE(out: &face_normal)
            generate_mesh_FLAT(vert: vert, norm: face_normal, alpha: rsm.alpha, mesh: &mesh)
        case RSM.RSMShadingType.flat.rawValue:
            calcNormal_FLAT(out: &face_normal, normalMat: normalMat, groupUsed: &shadeGroupUsed)
            generate_mesh_FLAT(vert: vert, norm: face_normal, alpha: rsm.alpha, mesh: &mesh)
        case RSM.RSMShadingType.smooth.rawValue:
            calcNormal_FLAT(out: &face_normal, normalMat: normalMat, groupUsed: &shadeGroupUsed)
            calcNormal_SMOOTH(normal: face_normal, groupUsed: shadeGroupUsed, group: &shadeGroup)
            generate_mesh_SMOOTH(vert: vert, shadeGroup: shadeGroup, alpha: rsm.alpha, mesh: &mesh)
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

            let t = Int(node.textureIndexes[Int(face.textureIndex)])

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j])

                let vertex = ModelVertex(
                    position: [vert[a + 0], vert[a + 1], vert[a + 2]],
                    normal: [norm[k + 0], norm[k + 1], norm[k + 2]],
                    textureCoordinate: [
                        node.tvertices[b].u,
                        node.tvertices[b].v
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

            let t = Int(node.textureIndexes[Int(face.textureIndex)])

            for j in 0..<3 {
                let a = Int(idx[j]) * 3
                let b = Int(tidx[j])

                let vertex = ModelVertex(
                    position: [vert[a + 0], vert[a + 1], vert[a + 2]],
                    normal: [norm[a + 0], norm[a + 1], norm[a + 2]],
                    textureCoordinate: [
                        node.tvertices[b].u,
                        node.tvertices[b].v
                    ],
                    alpha: Float(alpha) / 255
                )
                mesh[t].append(vertex)
            }
        }
    }
}
