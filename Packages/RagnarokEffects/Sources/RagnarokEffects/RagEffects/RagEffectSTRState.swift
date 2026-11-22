//
//  RagEffectSTRState.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/21.
//

import Foundation
import RagnarokFileFormats
import simd

/// Discrete 60Hz keyframe playback state mirroring `RagEffectState`'s STR playback
/// (`CRagEffect::InitEZ2STRFrame`, `CRagEffect::ProcessEZ2STR`, and `CRagEffect::RenderAniClip`).
public struct RagEffectSTRState: Sendable {
    public struct LayerTransform: Sendable, Equatable {
        public var position: SIMD2<Float> = .zero
        public var uv: SIMD8<Float> = .zero
        public var xy: SIMD8<Float> = .zero
        public var textureIndex: Float = 0
        public var animationType: Int32 = 0
        public var delay: Float = 0
        public var angle: Float = 0
        public var color: SIMD4<Float> = .zero
        public var sourceAlpha: Int32 = 5
        public var destinationAlpha: Int32 = 6
        public var multiTexturePreset: Int32 = 0

        public init() {}

        init(keyframe: STR.Keyframe) {
            self.position = keyframe.position
            self.uv = keyframe.uv
            self.xy = keyframe.xy
            self.textureIndex = keyframe.textureIndex
            self.animationType = keyframe.animationType
            self.delay = keyframe.delay
            self.angle = keyframe.angle
            self.color = keyframe.color
            self.sourceAlpha = keyframe.sourceAlpha
            self.destinationAlpha = keyframe.destinationAlpha
            self.multiTexturePreset = keyframe.multiTexturePreset
        }
    }

    public private(set) var currentLayer: Int = 0
    public private(set) var endLayer: Int = 0
    public private(set) var frameCounter: Int = 0
    public private(set) var loopCount: Int = 0
    public var loopLimit: Int

    public private(set) var currentKey: [Int] = []
    public private(set) var layerDrawn: [Bool] = []
    public private(set) var transforms: [LayerTransform] = []

    public private(set) var isInitialized: Bool = false

    public init(loopLimit: Int = 0) {
        self.loopLimit = loopLimit
    }

    /// Mirrors `CRagEffect::InitEZ2STRFrame()`.
    public mutating func reset(for str: STR) {
        let layerCount = str.layers.count
        currentLayer = 0
        frameCounter = 0
        endLayer = str.layers.reduce(into: 0) { count, layer in
            if !layer.keyframes.isEmpty {
                count += 1
            }
        }
        currentKey = Array(repeating: 0, count: layerCount)
        layerDrawn = Array(repeating: false, count: layerCount)
        transforms = Array(repeating: LayerTransform(), count: layerCount)
        isInitialized = true
    }

    /// Advances one 60Hz tick of `CRagEffect::ProcessEZ2STR(...)`.
    /// Returns `false` when all layers have finished and `loopCount > loopLimit`.
    @discardableResult
    public mutating func step(str: STR) -> Bool {
        if !isInitialized || currentKey.count != str.layers.count {
            reset(for: str)
        }

        if endLayer <= 0 {
            return false
        }

        if currentLayer >= endLayer {
            loopCount += 1
            if loopCount > loopLimit {
                for index in layerDrawn.indices {
                    layerDrawn[index] = false
                }
                return false
            }
            reset(for: str)
        }

        let currentFrame = Int32(frameCounter)
        var lastWrapRatio: Float = 0

        for layerIndex in 0..<str.layers.count {
            layerDrawn[layerIndex] = false
            let layer = str.layers[layerIndex]
            let keyCount = layer.keyframes.count
            let keyIndex = currentKey[layerIndex]

            if keyCount == 0 || keyIndex < 0 || keyIndex >= keyCount {
                continue
            }

            var activeIndex = keyIndex
            var key = layer.keyframes[activeIndex]
            let elapsed = currentFrame - key.frameIndex

            if elapsed < 0 {
                continue
            }

            if elapsed != 0 && activeIndex + 1 < keyCount && layer.keyframes[activeIndex + 1].frameIndex == currentFrame {
                activeIndex += 1
                if activeIndex >= keyCount - 1 {
                    currentKey[layerIndex] = -1
                    currentLayer += 1
                } else {
                    currentKey[layerIndex] = activeIndex
                }
                key = layer.keyframes[activeIndex]
            } else if keyCount == 1 {
                currentKey[layerIndex] = -1
                currentLayer += 1
            }

            if key.type == 0 {
                transforms[layerIndex] = LayerTransform(keyframe: key)

                if currentKey[layerIndex] != -1,
                   activeIndex + 1 < keyCount,
                   layer.keyframes[activeIndex + 1].frameIndex == key.frameIndex {
                    currentKey[layerIndex] = activeIndex + 1
                }

                layerDrawn[layerIndex] = true
                continue
            }

            var current = transforms[layerIndex]
            current.position += key.position
            current.uv += key.uv
            current.xy += key.xy
            current.color += key.color
            current.angle += key.angle

            let textureCount = layer.textures.count
            if textureCount > 0 {
                let textureCountFloat = Float(textureCount)
                switch key.animationType {
                case 1:
                    current.textureIndex += key.textureIndex
                case 2:
                    current.textureIndex += key.delay
                    if current.textureIndex >= textureCountFloat {
                        current.textureIndex = textureCountFloat - 1
                    }
                case 3:
                    let nextFrame = current.textureIndex + key.delay
                    current.textureIndex = nextFrame
                    if nextFrame >= textureCountFloat {
                        lastWrapRatio = Float(Int(nextFrame / textureCountFloat))
                        current.textureIndex = nextFrame - lastWrapRatio * textureCountFloat
                    }
                case 4:
                    var nextFrame = current.textureIndex - key.delay
                    if nextFrame < 0 {
                        nextFrame -= lastWrapRatio * textureCountFloat
                        lastWrapRatio = Float(Int(nextFrame / textureCountFloat))
                        if nextFrame < 0 {
                            nextFrame += textureCountFloat
                        }
                    }
                    current.textureIndex = nextFrame
                case 5:
                    if textureCount > 1 {
                        let span = textureCount - 1
                        let frame = Int(Float(elapsed) * key.delay + current.textureIndex)
                        let turns = frame / span
                        if (turns & 1) != 0 {
                            current.textureIndex = Float(span - (frame - turns * span))
                        } else {
                            current.textureIndex = Float(frame - turns * span)
                        }
                    } else {
                        current.textureIndex = 0
                    }
                default:
                    break
                }
            }

            transforms[layerIndex] = current
            layerDrawn[layerIndex] = true
        }

        frameCounter += 1
        return true
    }

    /// Converts the currently drawn layers into a `STREffectAnimation.Frame` for `STREffectRenderer`.
    public func makeFrame(for str: STR) -> STREffectAnimation.Frame {
        guard isInitialized else {
            return STREffectAnimation.Frame(sprites: [])
        }

        var sprites: [STREffectAnimation.Sprite] = []
        sprites.reserveCapacity(str.layers.count)

        for layerIndex in 0..<min(str.layers.count, layerDrawn.count) {
            guard layerDrawn[layerIndex] else {
                continue
            }

            let layer = str.layers[layerIndex]
            guard !layer.textures.isEmpty else {
                continue
            }

            let transform = transforms[layerIndex]
            let rawIndex = Int(transform.textureIndex)
            let clampedIndex = max(0, min(rawIndex, layer.textures.count - 1))
            let textureName = layer.textures[clampedIndex]

            sprites.append(
                STREffectAnimation.Sprite(
                    uv: transform.uv,
                    xy: transform.xy,
                    textureName: textureName,
                    position: transform.position,
                    angle: transform.angle,
                    color: transform.color,
                    sourceAlpha: transform.sourceAlpha,
                    destinationAlpha: transform.destinationAlpha,
                    multiTexturePreset: transform.multiTexturePreset
                )
            )
        }

        return STREffectAnimation.Frame(sprites: sprites)
    }
}
