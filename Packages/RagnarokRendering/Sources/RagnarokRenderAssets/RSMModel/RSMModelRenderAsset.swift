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
    public let rootNode: RSMModelNode?
    public let nodes: [RSMModelNode]
    public var meshes: [RSMModelMesh] = []
    public var boundingBox: RSMModelBoundingBox
    public let centerCorrection: SIMD3<Float>
    public var instance: RSMModelInstance
    public var lighting: WorldLighting
    public var textureImages: [String : CGImage]
    public let animationLength: Int32
    public let frameRatePerSecond: Float
    public let shadeType: Int32
    public let alpha: UInt8

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
        self.animationLength = rsm.animationLength
        self.frameRatePerSecond = rsm.fps
        self.shadeType = rsm.shadeType
        self.alpha = rsm.alpha

        let tree = RSMModelTreeBuilder(rsm: rsm).build()
        self.rootNode = tree.rootNode
        self.nodes = tree.nodes
        self.boundingBox = tree.boundingBox
        self.centerCorrection = tree.centerCorrection
        self.meshes = tree.legacyMeshes
    }
}
