//
//  Effect3DAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects

public struct Effect3DAsset: Sendable {
    public struct Layer: Sendable {
        public let imageIndex: Int
        public let sizeFactor: SIMD2<Float>
        public let offset: SIMD2<Float>
        public let angle: Float
        public let color: SIMD4<Float>
        public let isMirrored: Bool

        public init(
            imageIndex: Int,
            sizeFactor: SIMD2<Float>,
            offset: SIMD2<Float> = .zero,
            angle: Float = 0,
            color: SIMD4<Float> = [1, 1, 1, 1],
            isMirrored: Bool = false
        ) {
            self.imageIndex = imageIndex
            self.sizeFactor = sizeFactor
            self.offset = offset
            self.angle = angle
            self.color = color
            self.isMirrored = isMirrored
        }
    }

    public struct Frame: Sendable {
        public let layers: [Effect3DAsset.Layer]
    }

    public let definition: Effect3DDefinition
    public let images: [CGImage]
    public let frames: [Effect3DAsset.Frame]

    public init(definition: Effect3DDefinition, images: [CGImage], frames: [Effect3DAsset.Frame]) {
        self.definition = definition
        self.images = images
        self.frames = frames
    }
}
