//
//  STREffectAnimation.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2023/11/24.
//

import CoreGraphics
import Foundation
import RagnarokFileFormats

public struct STREffectAnimation: Sendable {
    public struct Frame: Sendable {
        public let sprites: [STREffectAnimation.Sprite]
    }

    public struct Sprite: Sendable {
        public let uv: SIMD8<Float>
        public let xy: SIMD8<Float>
        public let textureName: String

        public let position: SIMD2<Float>
        public let angle: Float
        public let color: SIMD4<Float>
        public let sourceAlpha: Int32
        public let destinationAlpha: Int32
        public let multiTexturePreset: Int32
    }

    public let str: STR
    public let textureImages: [String : CGImage]

    public var fps: Int {
        Int(str.fps)
    }

    public var frameCount: Int {
        max(0, Int(str.maxKeyframeIndex) + 1)
    }

    public var duration: TimeInterval {
        if fps > 0 {
            TimeInterval(frameCount) / TimeInterval(fps)
        } else {
            0
        }
    }

    public init(str: STR, textureImages: [String : CGImage]) {
        self.str = str
        self.textureImages = textureImages
    }

    public func frame(atElapsedTime elapsedTime: TimeInterval) -> STREffectAnimation.Frame? {
        guard frameCount > 0, fps > 0, elapsedTime >= 0 else {
            return nil
        }

        let frameIndex = Int(elapsedTime * TimeInterval(fps)) % frameCount
        return frame(atFrameIndex: frameIndex)
    }

    public func frame(atFrameIndex frameIndex: Int) -> STREffectAnimation.Frame {
        let frameIndex = Int32(frameIndex)

        var sprites: [STREffectAnimation.Sprite] = []
        sprites.reserveCapacity(str.layers.count)

        for layer in str.layers {
            if let sprite = evaluateLayer(layer, atFrameIndex: frameIndex) {
                sprites.append(sprite)
            }
        }

        return STREffectAnimation.Frame(sprites: sprites)
    }

    private func evaluateLayer(_ layer: STR.Layer, atFrameIndex frameIndex: Int32) -> STREffectAnimation.Sprite? {
        var lastFrame: Int32 = 0
        var lastSource: Int32 = 0
        var fromId = -1
        var toId = -1

        for (i, keyframe) in layer.keyframes.enumerated() {
            if keyframe.frameIndex <= frameIndex {
                if keyframe.type == 0 {
                    fromId = i
                }
                if keyframe.type == 1 {
                    toId = i
                }
            }
            lastFrame = max(lastFrame, keyframe.frameIndex)

            if keyframe.type == 0 {
                lastSource = max(lastSource, keyframe.frameIndex)
            }
        }

        // Nothing to render
        if fromId < 0 || (toId < 0 && lastFrame < frameIndex) {
            return nil
        }

        let from = layer.keyframes[fromId]
        let to = toId > -1 ? layer.keyframes[toId] : nil
        let delta = frameIndex - from.frameIndex

        guard from.textureIndex > -1, Int(from.textureIndex) < layer.textures.count else {
            return nil
        }

        // Static frame (or frame that can't be updated)
        if toId != fromId + 1 || to?.frameIndex != from.frameIndex {
            // No other source
            if to != nil && lastSource <= from.frameIndex {
                return nil
            }

            let textureName = layer.textures[Int(from.textureIndex)]
            return STREffectAnimation.Sprite(
                uv: from.uv,
                xy: from.xy,
                textureName: textureName,
                position: from.position,
                angle: from.angle,
                color: from.color,
                sourceAlpha: from.sourceAlpha,
                destinationAlpha: from.destinationAlpha,
                multiTexturePreset: from.multiTexturePreset
            )
        }

        guard let to, !layer.textures.isEmpty else {
            return nil
        }

        // Morph animation: compute texture index based on animationType
        let textureCount = layer.textures.count
        let rawFrame: Float
        switch to.animationType {
        case 1: // normal
            rawFrame = from.textureIndex + to.textureIndex * Float(delta)
        case 2: // stop at end
            rawFrame = min(from.textureIndex + to.delay * Float(delta), Float(textureCount - 1))
        case 3: // repeat
            rawFrame = (from.textureIndex + to.delay * Float(delta))
                .truncatingRemainder(dividingBy: Float(textureCount))
        case 4: // reverse
            var r = (from.textureIndex - to.delay * Float(delta))
                .truncatingRemainder(dividingBy: Float(textureCount))
            if r < 0 {
                r += Float(textureCount)
            }
            rawFrame = r
        default: // bug fix
            rawFrame = 0
        }
        let textureIndex = max(0, min(Int(rawFrame), textureCount - 1))
        let textureName = layer.textures[textureIndex]

        let uv = from.uv + to.uv * Float(delta)
        let xy = from.xy + to.xy * Float(delta)
        let position = from.position + to.position * Float(delta)
        let angle = from.angle + to.angle * Float(delta)
        let color = from.color + to.color * Float(delta)

        return STREffectAnimation.Sprite(
            uv: uv,
            xy: xy,
            textureName: textureName,
            position: position,
            angle: angle,
            color: color,
            sourceAlpha: from.sourceAlpha,
            destinationAlpha: from.destinationAlpha,
            multiTexturePreset: from.multiTexturePreset
        )
    }
}
