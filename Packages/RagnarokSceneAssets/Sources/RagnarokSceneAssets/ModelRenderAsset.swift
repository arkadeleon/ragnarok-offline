//
//  ModelRenderAsset.swift
//  RagnarokSceneAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import RagnarokRenderers
import simd

public struct ModelRenderAsset {
    public struct Instance {
        public var position: SIMD3<Float>
        public var rotation: SIMD3<Float>
        public var scale: SIMD3<Float>

        public init(position: SIMD3<Float>, rotation: SIMD3<Float>, scale: SIMD3<Float>) {
            self.position = position
            self.rotation = rotation
            self.scale = scale
        }
    }

    public var name: String
    public var model: Model
    public var textureImages: [String : CGImage]
    public var instances: [ModelRenderAsset.Instance]

    public init(
        name: String,
        model: Model,
        textureImages: [String : CGImage],
        instances: [ModelRenderAsset.Instance]
    ) {
        self.name = name
        self.model = model
        self.textureImages = textureImages
        self.instances = instances
    }
}
