//
//  RSMModelRenderAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import RagnarokCore
import RagnarokFileFormats
import RagnarokShaders
import simd

public struct RSMModelMesh: Sendable {
    public var vertices: [ModelVertex] = []
    public var textureName: String
}

public struct RSMModelBoundingBox: Sendable {
    public var min: SIMD3<Float> = [.infinity, .infinity, .infinity]
    public var max: SIMD3<Float> = [-.infinity, -.infinity, -.infinity]

    public var range: SIMD3<Float> {
        (max - min) / 2
    }

    public var center: SIMD3<Float> {
        (min + max) / 2
    }
}

public struct RSMModelInstance: Sendable {
    public static let identity = RSMModelInstance(position: .zero, rotation: .zero, scale: .one)

    public var position: SIMD3<Float>
    public var rotation: SIMD3<Float>
    public var scale: SIMD3<Float>

    public var matrix: simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix = matrix_translate(matrix, [position[0], position[1], position[2]])
        matrix = matrix_rotate(matrix, radians(rotation[2]), [0, 0, 1])
        matrix = matrix_rotate(matrix, radians(rotation[0]), [1, 0, 0])
        matrix = matrix_rotate(matrix, radians(rotation[1]), [0, 1, 0])
        matrix = matrix_scale(matrix, scale)
        return matrix
    }

    public init(position: SIMD3<Float>, rotation: SIMD3<Float>, scale: SIMD3<Float>) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
}

public struct RSMModelRenderAsset {
    public var name: String
    public var meshes: [RSMModelMesh] = []
    public var boundingBox: RSMModelBoundingBox
    public var instance: RSMModelInstance
    public var lighting: WorldLighting
    public var textureImages: [String : CGImage]

    public var textureNames: Set<String> {
        Set(meshes.map(\.textureName))
    }

    public init(
        name: String,
        rsm: RSM,
        instance: RSMModelInstance,
        lighting: WorldLighting,
        textureImages: [String : CGImage]
    ) {
        self.name = name
        self.instance = instance
        self.lighting = lighting
        self.textureImages = textureImages

        // Build node hierarchy.
        let wrappers = rsm.buildNodeHierarchy()

        // Set up transforms and bounding boxes for each node.
        let rootWrapper = wrappers.first(where: { $0.node.name == rsm.rootNodes.first })
        rootWrapper?.prepareTransforms()

        var boundingBox = RSMModelBoundingBox()
        for wrapper in wrappers {
            for i in 0..<3 {
                boundingBox.max[i] = max(boundingBox.max[i], wrapper.boundingBox.max[i])
                boundingBox.min[i] = min(boundingBox.min[i], wrapper.boundingBox.min[i])
            }
        }
        self.boundingBox = boundingBox

        // Compile mesh vertices for each node.
        var meshes: [RSMModelMesh] = []
        for wrapper in wrappers {
            let compiledMeshes = wrapper.compile(rsm: rsm, instanceMatrix: matrix_identity_float4x4, boundingBox: boundingBox)
            for (textureName, vertices) in compiledMeshes {
                let mesh = RSMModelMesh(vertices: vertices, textureName: textureName)
                meshes.append(mesh)
            }
        }
        self.meshes = meshes
    }
}

extension RSM {
    fileprivate func buildNodeHierarchy() -> [RSMModelNodeWrapper] {
        let wrappers = nodes.map(RSMModelNodeWrapper.init)
        let wrappersByName = Dictionary(grouping: wrappers, by: \.node.name)
        for wrapper in wrappers {
            guard let parents = wrappersByName[wrapper.node.parentName] else {
                continue
            }
            for parent in parents where parent.node.name != parent.node.parentName {
                parent.addChild(wrapper)
            }
        }
        return wrappers
    }
}

final class RSMModelNodeWrapper {
    let node: RSM.Node

    var boundingBox = RSMModelBoundingBox()

    weak var parent: RSMModelNodeWrapper?
    var children: [RSMModelNodeWrapper] = []

    var transformForChildren = matrix_identity_float4x4

    var worldTransformForChildren: simd_float4x4 {
        if let parent {
            parent.worldTransformForChildren * transformForChildren
        } else {
            transformForChildren
        }
    }

    var transform = matrix_identity_float4x4

    var worldTransform: simd_float4x4 {
        if let parent {
            parent.worldTransformForChildren * transform
        } else {
            transform
        }
    }

    init(node: RSM.Node) {
        self.node = node
    }

    func addChild(_ child: RSMModelNodeWrapper) {
        children.append(child)
        child.parent = self
    }

    func prepareTransforms() {
        transformForChildren = matrix_identity_float4x4
        transformForChildren = matrix_translate(transformForChildren, node.position)

        if node.rotationKeyframes.isEmpty {
            let quaternion = simd_quatf(angle: node.rotationAngle, axis: node.rotationAxis)
            let rotationMatrix = simd_float4x4(quaternion)
            transformForChildren *= rotationMatrix
        } else {
            let quaternion = node.rotationKeyframes[0].quaternion
            let rotationMatrix = simd_float4x4(quaternion)
            transformForChildren *= rotationMatrix
        }

        transformForChildren = matrix_scale(transformForChildren, node.scale)

        transform = transformForChildren
        transform = matrix_translate(transform, node.offset)
        transform = transform * simd_float4x4(node.transformMatrix)

        let matrix = worldTransform
        for vertex in node.vertices {
            let transformedVertex = matrix * SIMD4<Float>(vertex, 1)
            for i in 0..<3 {
                boundingBox.min[i] = min(transformedVertex[i], boundingBox.min[i])
                boundingBox.max[i] = max(transformedVertex[i], boundingBox.max[i])
            }
        }

        for child in children {
            child.prepareTransforms()
        }
    }

    func compile(
        rsm: RSM,
        instanceMatrix: simd_float4x4,
        boundingBox: RSMModelBoundingBox
    ) -> [String : [ModelVertex]] {
        var shadeGroup = [[SIMD3<Float>]](repeating: [], count: 32)
        var shadeGroupUsed = [Bool](repeating: false, count: 32)

        var matrix = matrix_identity_float4x4
        matrix = matrix_translate(matrix, [-boundingBox.center[0], -boundingBox.max[1], -boundingBox.center[2]])
        matrix = matrix * worldTransform

        let modelViewMatrix = instanceMatrix * matrix
        let normalMatrix = extractRotation(modelViewMatrix)

        var vertices: [SIMD3<Float>] = []
        for vertex in node.vertices {
            let transformed = modelViewMatrix * SIMD4<Float>(vertex, 1)
            vertices.append([transformed.x, transformed.y, transformed.z])
        }

        var faceNormals = [SIMD3<Float>](repeating: .zero, count: node.faces.count)

        var mesh: [String : [ModelVertex]] = [:]
        for textureName in node.textures {
            mesh[textureName] = []
        }

        switch rsm.shadeType {
        case RSM.RSMShadingType.none.rawValue:
            calcNormal_NONE(out: &faceNormals)
            generate_mesh_FLAT(vert: vertices, norm: faceNormals, alpha: rsm.alpha, mesh: &mesh)
        case RSM.RSMShadingType.flat.rawValue:
            calcNormal_FLAT(out: &faceNormals, normalMat: normalMatrix, groupUsed: &shadeGroupUsed)
            generate_mesh_FLAT(vert: vertices, norm: faceNormals, alpha: rsm.alpha, mesh: &mesh)
        case RSM.RSMShadingType.smooth.rawValue:
            calcNormal_FLAT(out: &faceNormals, normalMat: normalMatrix, groupUsed: &shadeGroupUsed)
            calcNormal_SMOOTH(normal: faceNormals, groupUsed: shadeGroupUsed, group: &shadeGroup)
            generate_mesh_SMOOTH(vert: vertices, shadeGroup: shadeGroup, alpha: rsm.alpha, mesh: &mesh)
        default:
            break
        }

        return mesh
    }

    func calcNormal_NONE(out: inout [SIMD3<Float>]) {
        for index in 0..<out.count {
            out[index].y = -1
        }
    }

    func calcNormal_FLAT(out: inout [SIMD3<Float>], normalMat: simd_float4x4, groupUsed: inout [Bool]) {
        for (faceIndex, face) in node.faces.enumerated() {
            let faceNormal = calcNormal(
                node.vertices[Int(face.vertexIndices[0])],
                node.vertices[Int(face.vertexIndices[1])],
                node.vertices[Int(face.vertexIndices[2])]
            )

            let transformedNormal = normalMat * SIMD4<Float>(faceNormal, 1)
            out[faceIndex] = [transformedNormal.x, transformedNormal.y, transformedNormal.z]

            groupUsed[Int(face.smoothGroup[0])] = true
        }
    }

    func calcNormal_SMOOTH(normal: [SIMD3<Float>], groupUsed: [Bool], group: inout [[SIMD3<Float>]]) {
        for smoothGroupIndex in 0..<32 {
            if groupUsed[smoothGroupIndex] == false {
                continue
            }

            group[smoothGroupIndex] = [SIMD3<Float>](repeating: .zero, count: node.vertices.count)
            var groupNormals = group[smoothGroupIndex]

            for vertexIndex in node.vertices.indices {
                var x: Float = 0
                var y: Float = 0
                var z: Float = 0

                for (faceIndex, face) in node.faces.enumerated() {
                    if face.smoothGroup[0] == smoothGroupIndex &&
                        (face.vertexIndices[0] == vertexIndex ||
                         face.vertexIndices[1] == vertexIndex ||
                         face.vertexIndices[2] == vertexIndex) {
                        x += normal[faceIndex].x
                        y += normal[faceIndex].y
                        z += normal[faceIndex].z
                    }
                }

                let length = 1 / sqrtf(x * x + y * y + z * z)
                groupNormals[vertexIndex] = [x * length, y * length, z * length]
            }

            group[smoothGroupIndex] = groupNormals
        }
    }

    func generate_mesh_FLAT(vert: [SIMD3<Float>], norm: [SIMD3<Float>], alpha: UInt8, mesh: inout [String : [ModelVertex]]) {
        for (faceIndex, face) in node.faces.enumerated() {
            let textureIndex = Int(face.textureIndex)
            let textureName = node.textures[textureIndex]

            for vertexIndex in 0..<3 {
                let positionIndex = Int(face.vertexIndices[vertexIndex])
                let textureVertexIndex = Int(face.tvertexIndices[vertexIndex])

                let vertex = ModelVertex(
                    position: vert[positionIndex],
                    normal: norm[faceIndex],
                    textureCoordinate: [
                        node.tvertices[textureVertexIndex].u * 0.98 + 0.01,
                        node.tvertices[textureVertexIndex].v * 0.98 + 0.01,
                    ],
                    alpha: Float(alpha) / 255
                )
                mesh[textureName]?.append(vertex)
            }
        }
    }

    func generate_mesh_SMOOTH(vert: [SIMD3<Float>], shadeGroup: [[SIMD3<Float>]], alpha: UInt8, mesh: inout [String : [ModelVertex]]) {
        for face in node.faces {
            let normals = shadeGroup[Int(face.smoothGroup[0])]

            let textureIndex = Int(face.textureIndex)
            let textureName = node.textures[textureIndex]

            for vertexIndex in 0..<3 {
                let positionIndex = Int(face.vertexIndices[vertexIndex])
                let textureVertexIndex = Int(face.tvertexIndices[vertexIndex])

                let vertex = ModelVertex(
                    position: vert[positionIndex],
                    normal: normals[positionIndex],
                    textureCoordinate: [
                        node.tvertices[textureVertexIndex].u * 0.98 + 0.01,
                        node.tvertices[textureVertexIndex].v * 0.98 + 0.01,
                    ],
                    alpha: Float(alpha) / 255
                )
                mesh[textureName]?.append(vertex)
            }
        }
    }
}
