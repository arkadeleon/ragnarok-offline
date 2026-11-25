//
//  EffectSpriteAsset.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/25.
//

import Foundation
import Metal
import RagnarokFileFormats
import simd

public final class EffectSpriteAsset: @unchecked Sendable {
    public struct SpriteImage: @unchecked Sendable {
        public let texture: (any MTLTexture)?
        public let width: Int
        public let height: Int

        public init(texture: (any MTLTexture)?, width: Int, height: Int) {
            self.texture = texture
            self.width = width
            self.height = height
        }
    }

    public struct Cell: Sendable {
        public let offset: SIMD2<Float>
        public let spriteIndex: Int32
        public let spriteType: Int32
        public let isMirrored: Bool
        public let scale: SIMD2<Float>
        public let rotationDegrees: Float
        public let color: SIMD4<Float>

        public init(
            offset: SIMD2<Float> = .zero,
            spriteIndex: Int32 = 0,
            spriteType: Int32 = 0,
            isMirrored: Bool = false,
            scale: SIMD2<Float> = SIMD2<Float>(1, 1),
            rotationDegrees: Float = 0,
            color: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1)
        ) {
            self.offset = offset
            self.spriteIndex = spriteIndex
            self.spriteType = spriteType
            self.isMirrored = isMirrored
            self.scale = scale
            self.rotationDegrees = rotationDegrees
            self.color = color
        }

        public init(layer: ACT.Layer) {
            self.offset = SIMD2<Float>(Float(layer.offset.x), Float(layer.offset.y))
            self.spriteIndex = layer.spriteIndex
            self.spriteType = layer.spriteType
            self.isMirrored = (layer.isMirrored & 1) != 0
            self.scale = layer.scale
            self.rotationDegrees = Float(layer.rotationAngle)
            self.color = SIMD4<Float>(
                Float(layer.color.red) / 255.0,
                Float(layer.color.green) / 255.0,
                Float(layer.color.blue) / 255.0,
                Float(layer.color.alpha) / 255.0
            )
        }
    }

    public struct Frame: Sendable {
        public let cells: [Cell]

        public init(cells: [Cell]) {
            self.cells = cells
        }
    }

    public let actions: [[Frame]]
    public let indexedSprites: [SpriteImage?]
    public let rgbaSprites: [SpriteImage?]

    public init(
        actions: [[Frame]],
        indexedSprites: [SpriteImage?],
        rgbaSprites: [SpriteImage?] = []
    ) {
        self.actions = actions
        self.indexedSprites = indexedSprites
        self.rgbaSprites = rgbaSprites
    }

    public convenience init(
        act: ACT,
        indexedSprites: [SpriteImage?],
        rgbaSprites: [SpriteImage?]
    ) {
        let actions = act.actions.map { action in
            action.frames.map { frame in
                Frame(cells: frame.layers.map(Cell.init(layer:)))
            }
        }
        self.init(actions: actions, indexedSprites: indexedSprites, rgbaSprites: rgbaSprites)
    }

    public func frameCount(forAction actionIndex: Int) -> Int {
        guard !actions.isEmpty else {
            return 0
        }
        let resolvedAction = actions.indices.contains(actionIndex) ? actionIndex : 0
        return actions[resolvedAction].count
    }

    public func frame(actionIndex: Int, frameIndex: Int) -> Frame? {
        guard !actions.isEmpty else {
            return nil
        }
        let resolvedAction = actions.indices.contains(actionIndex) ? actionIndex : 0
        let frames = actions[resolvedAction]
        guard !frames.isEmpty else {
            return nil
        }
        let resolvedFrame = frames.indices.contains(frameIndex) ? frameIndex : (abs(frameIndex) % frames.count)
        return frames[resolvedFrame]
    }

    public func spriteImage(spriteType: Int32, spriteIndex: Int32) -> SpriteImage? {
        guard spriteIndex >= 0 else {
            return nil
        }
        let index = Int(spriteIndex)
        if spriteType == 1 {
            guard rgbaSprites.indices.contains(index) else {
                return nil
            }
            return rgbaSprites[index]
        } else {
            guard indexedSprites.indices.contains(index) else {
                return nil
            }
            return indexedSprites[index]
        }
    }
}
