//
//  Model.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/27.
//

import Metal
import simd
import ROFileFormats
import ROShaders

public struct ModelMesh {
    public var vertices: [ModelVertex] = []
    public var texture: MTLTexture?
}

public struct ModelBoundingBox {
    public var min: SIMD3<Float> = [.infinity, .infinity, .infinity]
    public var max: SIMD3<Float> = [-.infinity, -.infinity, -.infinity]

    public var range: SIMD3<Float> {
        (max - min) / 2
    }

    public var center: SIMD3<Float> {
        (min + max) / 2
    }
}

public struct Model {
    public var meshes: [ModelMesh] = []
    public var boundingBox: ModelBoundingBox

    public init(rsm: RSM, instance: float4x4, textureProvider: (String) -> MTLTexture?) {
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

    public static func createInstance(position: SIMD3<Float>, rotation: SIMD3<Float>, scale: SIMD3<Float>, width: Float, height: Float) -> float4x4 {
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

    var worldTransformForChildren: float4x4 {
        if let parent {
            return parent.worldTransformForChildren * transformForChildren
        } else {
            return transformForChildren
        }
    }

    var transform = matrix_identity_float4x4

    var worldTransform: float4x4 {
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

        transform = transform * float4x4(node.transformationMatrix)

        let matrix = worldTransform
        for vertex in node.vertices {
            let vertex = matrix * SIMD4<Float>(vertex, 1)

            for j in 0..<3 {
                box.min[j] = min(vertex[j], box.min[j])
                box.max[j] = max(vertex[j], box.max[j])
            }
        }

        for child in children {
            child.calcBoundingBox(wrappers: wrappers)
        }
    }

    func compile(rsm: RSM, instance_matrix: float4x4, boundingBox: ModelBoundingBox) -> [[ModelVertex]] {
        var shadeGroup = [[SIMD3<Float>]](repeating: [], count: 32)
        var shadeGroupUsed = [Bool](repeating: false, count: 32)

        var matrix = matrix_identity_float4x4
        matrix = matrix_translate(matrix, [-boundingBox.center[0], -boundingBox.max[1], -boundingBox.center[2]])
        matrix = matrix * worldTransform

//        if rsm.nodes.count == 1 {
//            matrix = matrix_translate(matrix, node.offset)
//        }
//
//        matrix = matrix * float4x4(node.transformationMatrix)

        // modelMatrix = instance * translate * worldTransform
        let modelViewMat = instance_matrix * matrix
        let normalMat = extractRotation(modelViewMat)

        var vertices: [SIMD3<Float>] = []
        for vertex in node.vertices {
            let v = modelViewMat * SIMD4<Float>(vertex, 1)
            vertices.append([v.x, v.y, v.z])
        }

        var face_normal = [SIMD3<Float>](repeating: .zero, count: node.faces.count)

        let maxTexture = node.textureIndexes.max() ?? 0
        var mesh = [[ModelVertex]](repeating: [], count: Int(maxTexture) + 1)

        switch rsm.shadeType {
        case RSM.RSMShadingType.none.rawValue:
            calcNormal_NONE(out: &face_normal)
            generate_mesh_FLAT(vert: vertices, norm: face_normal, alpha: rsm.alpha, mesh: &mesh)
        case RSM.RSMShadingType.flat.rawValue:
            calcNormal_FLAT(out: &face_normal, normalMat: normalMat, groupUsed: &shadeGroupUsed)
            generate_mesh_FLAT(vert: vertices, norm: face_normal, alpha: rsm.alpha, mesh: &mesh)
        case RSM.RSMShadingType.smooth.rawValue:
            calcNormal_FLAT(out: &face_normal, normalMat: normalMat, groupUsed: &shadeGroupUsed)
            calcNormal_SMOOTH(normal: face_normal, groupUsed: shadeGroupUsed, group: &shadeGroup)
            generate_mesh_SMOOTH(vert: vertices, shadeGroup: shadeGroup, alpha: rsm.alpha, mesh: &mesh)
        default:
            break
        }

        return mesh
    }

    func calcNormal_NONE(out: inout [SIMD3<Float>]) {
        for i in 0..<out.count {
            out[i].y = -1
        }
    }

    func calcNormal_FLAT(out: inout [SIMD3<Float>], normalMat: float4x4, groupUsed: inout [Bool]) {
        var j = 0
        for face in node.faces {
            let temp_vec = calcNormal(
                node.vertices[Int(face.vertidx[0])],
                node.vertices[Int(face.vertidx[1])],
                node.vertices[Int(face.vertidx[2])]
            )

            let n = normalMat * SIMD4<Float>(temp_vec, 1)
            out[j] = [n.x, n.y, n.z]

            groupUsed[Int(face.smoothGroup[0])] = true

            j += 1
        }
    }

    func calcNormal_SMOOTH(normal: [SIMD3<Float>], groupUsed: [Bool], group: inout [[SIMD3<Float>]]) {
        for j in 0..<32 {
            if groupUsed[j] == false {
                continue
            }

            group[j] = [SIMD3<Float>](repeating: .zero, count: node.vertices.count)
            var norm = group[j]

            var l = 0
            for v in 0..<node.vertices.count {
                var x: Float = 0
                var y: Float = 0
                var z: Float = 0

                var k = 0
                for face in node.faces {
                    if face.smoothGroup[0] == j && (face.vertidx[0] == v || face.vertidx[1] == v || face.vertidx[2] == v) {
                        x += normal[k].x
                        y += normal[k].y
                        z += normal[k].z
                    }

                    k += 1
                }

                let len = 1 / sqrtf(x * x + y * y + z * z)
                norm[l] = [x * len, y * len, z * len]

                l += 1
            }

            group[j] = norm
        }
    }

    func generate_mesh_FLAT(vert: [SIMD3<Float>], norm: [SIMD3<Float>], alpha: UInt8, mesh: inout [[ModelVertex]]) {
        var k = 0
        for face in node.faces {
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(node.textureIndexes[Int(face.textureIndex)])

            for j in 0..<3 {
                let a = Int(idx[j])
                let b = Int(tidx[j])

                let vertex = ModelVertex(
                    position: vert[a],
                    normal: norm[k],
                    textureCoordinate: [
                        node.tvertices[b].u,
                        node.tvertices[b].v
                    ],
                    alpha: Float(alpha) / 255
                )
                mesh[t].append(vertex)
            }

            k += 1
        }
    }

    func generate_mesh_SMOOTH(vert: [SIMD3<Float>], shadeGroup: [[SIMD3<Float>]], alpha: UInt8, mesh: inout [[ModelVertex]]) {
        for face in node.faces {
            let norm = shadeGroup[Int(face.smoothGroup[0])]
            let idx = face.vertidx
            let tidx = face.tvertidx

            let t = Int(node.textureIndexes[Int(face.textureIndex)])

            for j in 0..<3 {
                let a = Int(idx[j])
                let b = Int(tidx[j])

                let vertex = ModelVertex(
                    position: vert[a],
                    normal: norm[a],
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
