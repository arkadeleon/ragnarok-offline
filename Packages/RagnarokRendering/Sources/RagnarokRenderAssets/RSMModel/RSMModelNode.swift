//
//  RSMModelNode.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/3.
//

import RagnarokFileFormats
import RagnarokShaders
import simd

public struct RSMModelNodeMesh: Sendable {
    public let textureName: String
    public let textureIndex: Int32
    public let vertices: [ModelVertex]
}

public struct RSMModelPositionKeyframe: Sendable {
    public var frame: Int32
    public var position: SIMD3<Float>
    public var data: Int32

    init(from keyframe: RSM.PositionKeyframe) {
        frame = keyframe.frame
        position = keyframe.position
        data = Int32(keyframe.data)
    }

    init(from keyframe: RSM.Node.PositionKeyframe) {
        frame = keyframe.frame
        position = keyframe.position
        data = keyframe.data
    }
}

public struct RSMModelTextureAnimationTrack: Sendable {
    public let type: Int32
    public let keyframes: [RSM.Node.TextureAnimationKeyframe]
}

public struct RSMModelTextureAnimation: Sendable {
    public let textureIndex: Int32
    public let tracks: [RSMModelTextureAnimationTrack]
}

public final class RSMModelNode: @unchecked Sendable {
    public let index: Int
    public let name: String
    public internal(set) weak var parent: RSMModelNode?
    public let children: [RSMModelNode]

    public let vertices: [SIMD3<Float>]
    public let tvertices: [RSM.Node.TextureVertex]
    public let faces: [RSM.Face]
    public let textures: [String]

    public let position: SIMD3<Float>
    public let rotationAngle: Float
    public let rotationAxis: SIMD3<Float>
    public let scale: SIMD3<Float>
    public let offset: SIMD3<Float>
    public let transformMatrix: simd_float3x3

    public let positionKeyframes: [RSMModelPositionKeyframe]
    public let rotationKeyframes: [RSM.Node.RotationKeyframe]
    public let scaleKeyframes: [RSM.Node.ScaleKeyframe]
    public let textureAnimations: [RSMModelTextureAnimation]

    public let meshes: [RSMModelNodeMesh]

    init(
        index: Int,
        name: String,
        children: [RSMModelNode],
        vertices: [SIMD3<Float>],
        tvertices: [RSM.Node.TextureVertex],
        faces: [RSM.Face],
        textures: [String],
        position: SIMD3<Float>,
        rotationAngle: Float,
        rotationAxis: SIMD3<Float>,
        scale: SIMD3<Float>,
        offset: SIMD3<Float>,
        transformMatrix: simd_float3x3,
        positionKeyframes: [RSMModelPositionKeyframe],
        rotationKeyframes: [RSM.Node.RotationKeyframe],
        scaleKeyframes: [RSM.Node.ScaleKeyframe],
        textureAnimations: [RSMModelTextureAnimation],
        meshes: [RSMModelNodeMesh]
    ) {
        self.index = index
        self.name = name
        self.children = children
        self.vertices = vertices
        self.tvertices = tvertices
        self.faces = faces
        self.textures = textures
        self.position = position
        self.rotationAngle = rotationAngle
        self.rotationAxis = rotationAxis
        self.scale = scale
        self.offset = offset
        self.transformMatrix = transformMatrix
        self.positionKeyframes = positionKeyframes
        self.rotationKeyframes = rotationKeyframes
        self.scaleKeyframes = scaleKeyframes
        self.textureAnimations = textureAnimations
        self.meshes = meshes
    }
}
