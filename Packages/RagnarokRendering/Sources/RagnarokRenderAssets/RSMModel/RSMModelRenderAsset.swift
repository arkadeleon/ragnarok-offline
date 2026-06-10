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

public struct RSMModelRenderAsset {
    public var name: String
    public let rootNode: RSMModelNode?
    public let nodes: [RSMModelNode]
    public var boundingBox: RSMModelBoundingBox
    public let centerCorrection: SIMD3<Float>
    public var instance: RSMModelInstance
    public var textureImages: [String : CGImage]
    public let fps: Float
    public let animationLength: Int32

    public init(
        name: String,
        rsm: RSM,
        instance: RSMModelInstance,
        textureImages: [String : CGImage]
    ) {
        self.name = name
        self.instance = instance
        self.textureImages = textureImages
        self.fps = rsm.fps
        self.animationLength = rsm.animationLength

        let tree = RSMModelTreeBuilder(rsm: rsm).build()
        self.rootNode = tree.rootNode
        self.nodes = tree.nodes
        self.boundingBox = tree.boundingBox
        self.centerCorrection = tree.centerCorrection
    }
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
