//
//  RSMModelTreeBuilder.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/3.
//

import RagnarokCore
import RagnarokFileFormats
import RagnarokShaders
import simd

/// Turns a parsed `RSM` into a node tree, a flat DFS-ordered node array, the model's
/// bounding box, and its center-correction offset. Each backend renders the tree
/// directly — there is no longer a pre-baked flat mesh array.
final class RSMModelTreeBuilder {
    struct Result {
        let rootNode: RSMModelNode?
        let nodes: [RSMModelNode]
        let boundingBox: RSMModelBoundingBox
        let centerCorrection: SIMD3<Float>
    }

    let rsm: RSM

    init(rsm: RSM) {
        self.rsm = rsm
    }

    func build() -> Result {
        // Step 1: Create builders, one per RSM node, in file order.
        let rootName = rsm.rootNodes.first ?? rsm.nodes.first?.name
        let legacyPositionKeyframes = rsm.positionKeyframes.map(RSMModelPositionKeyframe.init(from:))

        let builders: [RSMModelNodeBuilder] = rsm.nodes.map { rsmNode in
            var positionKeyframes = rsmNode.positionKeyframes.map(RSMModelPositionKeyframe.init(from:))
            if rsmNode.name == rootName, !legacyPositionKeyframes.isEmpty {
                positionKeyframes.append(contentsOf: legacyPositionKeyframes)
                positionKeyframes.sort { $0.frame < $1.frame }
            }
            return RSMModelNodeBuilder(
                rsmNode: rsmNode,
                positionKeyframes: positionKeyframes,
                textureAnimations: makeTextureAnimations(from: rsmNode.textureKeyframeGroups)
            )
        }

        // Step 2: Wire parent/children references by name.
        let buildersByName = Dictionary(grouping: builders, by: { $0.rsmNode.name })
        for builder in builders {
            let parentName = builder.rsmNode.parentName
            guard parentName != builder.rsmNode.name,
                  let parents = buildersByName[parentName] else {
                continue
            }
            for parent in parents where parent.rsmNode.name != parent.rsmNode.parentName {
                parent.children.append(builder)
                builder.parent = parent
            }
        }

        // Step 3: DFS-assign indices starting from the root.
        let rootBuilder = builders.first(where: { $0.rsmNode.name == rootName })
        var nextIndex = 0
        func assignIndex(_ builder: RSMModelNodeBuilder) {
            builder.index = nextIndex
            nextIndex += 1
            for child in builder.children {
                assignIndex(child)
            }
        }
        if let rootBuilder {
            assignIndex(rootBuilder)
        }
        // Defensive: any node unreachable from the root still gets an index.
        for builder in builders where builder.index < 0 {
            builder.index = nextIndex
            nextIndex += 1
        }

        // Step 4: Compute per-node rest-pose world transforms by DFS.
        var worldTransforms = [simd_float4x4](repeating: matrix_identity_float4x4, count: builders.count)
        func computeWorldTransforms(_ builder: RSMModelNodeBuilder, parentChildrenWorld: simd_float4x4) {
            let local = restPoseTransformForChildren(builder.rsmNode)
            let transform = local
                * matrix_translate(matrix_identity_float4x4, builder.rsmNode.offset)
                * simd_float4x4(builder.rsmNode.transformMatrix)
            let worldChildren = parentChildrenWorld * local
            let world = parentChildrenWorld * transform
            worldTransforms[builder.index] = world
            for child in builder.children {
                computeWorldTransforms(child, parentChildrenWorld: worldChildren)
            }
        }
        if let rootBuilder {
            computeWorldTransforms(rootBuilder, parentChildrenWorld: matrix_identity_float4x4)
        }
        for builder in builders where builder.parent == nil && builder !== rootBuilder {
            computeWorldTransforms(builder, parentChildrenWorld: matrix_identity_float4x4)
        }

        // Step 5: Bounding box from raw vertices in world space.
        var boundingBox = RSMModelBoundingBox()
        for builder in builders {
            let M = worldTransforms[builder.index]
            for vertex in builder.rsmNode.vertices {
                let p = M * SIMD4<Float>(vertex, 1)
                for i in 0..<3 {
                    boundingBox.min[i] = Swift.min(boundingBox.min[i], p[i])
                    boundingBox.max[i] = Swift.max(boundingBox.max[i], p[i])
                }
            }
        }
        let centerCorrection = SIMD3<Float>(
            -boundingBox.center[0],
            -boundingBox.max[1],
            -boundingBox.center[2]
        )

        // Step 6: Compile node-local meshes (identity transform; vertices and normals stay in node space).
        for builder in builders {
            builder.meshes = compileNodeMeshes(
                rsmNode: builder.rsmNode,
                shadeType: rsm.shadeType,
                alpha: rsm.alpha,
                positionMatrix: matrix_identity_float4x4,
                normalMatrix: matrix_identity_float4x4
            )
        }

        // Step 7: Materialize the immutable node tree. Builder index is preserved so the
        // resulting `nodes` array satisfies nodes[i].index == i.
        var nodesByIndex = [RSMModelNode?](repeating: nil, count: builders.count)
        func materialize(_ builder: RSMModelNodeBuilder) -> RSMModelNode {
            let childNodes = builder.children.map(materialize)
            let node = RSMModelNode(
                index: builder.index,
                name: builder.rsmNode.name,
                children: childNodes,
                vertices: builder.rsmNode.vertices,
                tvertices: builder.rsmNode.tvertices,
                faces: builder.rsmNode.faces,
                textures: builder.rsmNode.textures,
                position: builder.rsmNode.position,
                rotationAngle: builder.rsmNode.rotationAngle,
                rotationAxis: builder.rsmNode.rotationAxis,
                scale: builder.rsmNode.scale,
                offset: builder.rsmNode.offset,
                transformMatrix: builder.rsmNode.transformMatrix,
                positionKeyframes: builder.positionKeyframes,
                rotationKeyframes: builder.rsmNode.rotationKeyframes,
                scaleKeyframes: builder.rsmNode.scaleKeyframes,
                textureAnimations: builder.textureAnimations,
                meshes: builder.meshes
            )
            for child in childNodes {
                child.parent = node
            }
            nodesByIndex[builder.index] = node
            return node
        }
        let rootNode = rootBuilder.map(materialize)
        for builder in builders where builder.parent == nil && builder !== rootBuilder {
            _ = materialize(builder)
        }
        let nodes = nodesByIndex.compactMap { $0 }

        return Result(
            rootNode: rootNode,
            nodes: nodes,
            boundingBox: boundingBox,
            centerCorrection: centerCorrection
        )
    }
}

private final class RSMModelNodeBuilder {
    let rsmNode: RSM.Node
    var positionKeyframes: [RSMModelPositionKeyframe]
    var textureAnimations: [RSMModelTextureAnimation]
    weak var parent: RSMModelNodeBuilder?
    var children: [RSMModelNodeBuilder] = []
    var index: Int = -1
    var meshes: [RSMModelNodeMesh] = []

    init(
        rsmNode: RSM.Node,
        positionKeyframes: [RSMModelPositionKeyframe],
        textureAnimations: [RSMModelTextureAnimation]
    ) {
        self.rsmNode = rsmNode
        self.positionKeyframes = positionKeyframes
        self.textureAnimations = textureAnimations
    }
}

// MARK: - Rest-pose helpers

private func restPoseTransformForChildren(_ node: RSM.Node) -> simd_float4x4 {
    var m = matrix_identity_float4x4
    m = matrix_translate(m, node.position)
    let quaternion: simd_quatf
    if node.rotationKeyframes.isEmpty {
        quaternion = simd_quatf(angle: node.rotationAngle, axis: node.rotationAxis)
    } else {
        quaternion = node.rotationKeyframes[0].quaternion
    }
    m *= simd_float4x4(quaternion)
    m = matrix_scale(m, node.scale)
    return m
}

// MARK: - Texture animation conversion

private func makeTextureAnimations(
    from groups: [RSM.Node.TextureKeyframeGroup]
) -> [RSMModelTextureAnimation] {
    groups.map { group in
        RSMModelTextureAnimation(
            textureIndex: group.textureIndex,
            tracks: group.textureAnimations.map { animation in
                RSMModelTextureAnimationTrack(type: animation.type, keyframes: animation.keyframes)
            }
        )
    }
}

// MARK: - Node mesh compilation

private func compileNodeMeshes(
    rsmNode: RSM.Node,
    shadeType: Int32,
    alpha: UInt8,
    positionMatrix: simd_float4x4,
    normalMatrix: simd_float4x4
) -> [RSMModelNodeMesh] {
    var shadeGroup = [[SIMD3<Float>]](repeating: [], count: 32)
    var shadeGroupUsed = [Bool](repeating: false, count: 32)

    var vertices: [SIMD3<Float>] = []
    vertices.reserveCapacity(rsmNode.vertices.count)
    for vertex in rsmNode.vertices {
        let transformed = positionMatrix * SIMD4<Float>(vertex, 1)
        vertices.append([transformed.x, transformed.y, transformed.z])
    }

    var faceNormals = [SIMD3<Float>](repeating: .zero, count: rsmNode.faces.count)

    var verticesByTexture = [Int32 : [ModelVertex]]()
    for textureIndex in 0..<rsmNode.textures.count {
        verticesByTexture[Int32(textureIndex)] = []
    }

    switch shadeType {
    case RSM.RSMShadingType.none.rawValue:
        calcNormal_NONE(out: &faceNormals)
        generate_mesh_FLAT(
            rsmNode: rsmNode,
            vert: vertices,
            norm: faceNormals,
            alpha: alpha,
            mesh: &verticesByTexture
        )
    case RSM.RSMShadingType.flat.rawValue:
        calcNormal_FLAT(
            rsmNode: rsmNode,
            out: &faceNormals,
            normalMat: normalMatrix,
            groupUsed: &shadeGroupUsed
        )
        generate_mesh_FLAT(
            rsmNode: rsmNode,
            vert: vertices,
            norm: faceNormals,
            alpha: alpha,
            mesh: &verticesByTexture
        )
    case RSM.RSMShadingType.smooth.rawValue:
        calcNormal_FLAT(
            rsmNode: rsmNode,
            out: &faceNormals,
            normalMat: normalMatrix,
            groupUsed: &shadeGroupUsed
        )
        calcNormal_SMOOTH(
            rsmNode: rsmNode,
            normal: faceNormals,
            groupUsed: shadeGroupUsed,
            group: &shadeGroup
        )
        generate_mesh_SMOOTH(
            rsmNode: rsmNode,
            vert: vertices,
            shadeGroup: shadeGroup,
            alpha: alpha,
            mesh: &verticesByTexture
        )
    default:
        break
    }

    return rsmNode.textures.enumerated().map { (textureIndex, textureName) in
        RSMModelNodeMesh(
            textureName: textureName,
            textureIndex: Int32(textureIndex),
            vertices: verticesByTexture[Int32(textureIndex)] ?? []
        )
    }
}

private func calcNormal_NONE(out: inout [SIMD3<Float>]) {
    for index in 0..<out.count {
        out[index].y = -1
    }
}

private func calcNormal_FLAT(
    rsmNode: RSM.Node,
    out: inout [SIMD3<Float>],
    normalMat: simd_float4x4,
    groupUsed: inout [Bool]
) {
    for (faceIndex, face) in rsmNode.faces.enumerated() {
        let faceNormal = calcNormal(
            rsmNode.vertices[Int(face.vertexIndices[0])],
            rsmNode.vertices[Int(face.vertexIndices[1])],
            rsmNode.vertices[Int(face.vertexIndices[2])]
        )

        let transformedNormal = normalMat * SIMD4<Float>(faceNormal, 1)
        out[faceIndex] = [transformedNormal.x, transformedNormal.y, transformedNormal.z]

        groupUsed[Int(face.smoothGroup[0])] = true
    }
}

private func calcNormal_SMOOTH(
    rsmNode: RSM.Node,
    normal: [SIMD3<Float>],
    groupUsed: [Bool],
    group: inout [[SIMD3<Float>]]
) {
    for smoothGroupIndex in 0..<32 {
        if groupUsed[smoothGroupIndex] == false {
            continue
        }

        group[smoothGroupIndex] = [SIMD3<Float>](repeating: .zero, count: rsmNode.vertices.count)
        var groupNormals = group[smoothGroupIndex]

        for vertexIndex in rsmNode.vertices.indices {
            var x: Float = 0
            var y: Float = 0
            var z: Float = 0

            for (faceIndex, face) in rsmNode.faces.enumerated() {
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

private func generate_mesh_FLAT(
    rsmNode: RSM.Node,
    vert: [SIMD3<Float>],
    norm: [SIMD3<Float>],
    alpha: UInt8,
    mesh: inout [Int32 : [ModelVertex]]
) {
    for (faceIndex, face) in rsmNode.faces.enumerated() {
        let textureIndex = face.textureIndex
        for vertexIndex in 0..<3 {
            let positionIndex = Int(face.vertexIndices[vertexIndex])
            let textureVertexIndex = Int(face.tvertexIndices[vertexIndex])

            let vertex = ModelVertex(
                position: vert[positionIndex],
                normal: norm[faceIndex],
                textureCoordinate: [
                    rsmNode.tvertices[textureVertexIndex].u * 0.98 + 0.01,
                    rsmNode.tvertices[textureVertexIndex].v * 0.98 + 0.01,
                ],
                alpha: Float(alpha) / 255
            )
            mesh[Int32(textureIndex), default: []].append(vertex)
        }
    }
}

private func generate_mesh_SMOOTH(
    rsmNode: RSM.Node,
    vert: [SIMD3<Float>],
    shadeGroup: [[SIMD3<Float>]],
    alpha: UInt8,
    mesh: inout [Int32 : [ModelVertex]]
) {
    for face in rsmNode.faces {
        let normals = shadeGroup[Int(face.smoothGroup[0])]
        let textureIndex = face.textureIndex
        for vertexIndex in 0..<3 {
            let positionIndex = Int(face.vertexIndices[vertexIndex])
            let textureVertexIndex = Int(face.tvertexIndices[vertexIndex])

            let vertex = ModelVertex(
                position: vert[positionIndex],
                normal: normals[positionIndex],
                textureCoordinate: [
                    rsmNode.tvertices[textureVertexIndex].u * 0.98 + 0.01,
                    rsmNode.tvertices[textureVertexIndex].v * 0.98 + 0.01,
                ],
                alpha: Float(alpha) / 255
            )
            mesh[Int32(textureIndex), default: []].append(vertex)
        }
    }
}
