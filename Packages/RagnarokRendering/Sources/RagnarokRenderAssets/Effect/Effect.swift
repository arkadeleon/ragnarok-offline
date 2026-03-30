//
//  Effect.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2023/11/24.
//

import RagnarokFileFormats
import RagnarokShaders

public struct Effect {
    public var fps: Int
    public var frames: [Frame] = []

    public init(str: STR) {
        fps = Int(str.fps)

        let frameCount = str.maxKeyframeIndex + 1
        for frameIndex in 0..<frameCount {
            var sprites: [Sprite] = []

            for layer in str.layers {
                var lastFrame = 0
                var lastSource = 0
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
                    lastFrame = max(lastFrame, Int(keyframe.frameIndex))

                    if keyframe.type == 0 {
                        lastSource = max(lastSource, Int(keyframe.frameIndex))
                    }
                }

                // Nothing to render
                if fromId < 0 || (toId < 0 && lastFrame < frameIndex) {
                    continue
                }

                let from  = layer.keyframes[fromId]
                let to    = toId > -1 ? layer.keyframes[toId] : nil
                let delta = frameIndex - from.frameIndex

                guard from.textureIndex > -1 else {
                    continue
                }

                // Static frame (or frame that can't be updated)
                if (toId != fromId + 1 || to?.frameIndex != from.frameIndex) {
                    // No other source
                    if (to != nil && lastSource <= from.frameIndex) {
                        continue
                    }

                    let textureName = layer.textures[Int(from.textureIndex)]
                    let sprite = Sprite(
                        uv: from.uv,
                        xy: from.xy,
                        textureName: textureName,
                        position: from.position,
                        angle: from.angle,
                        color: from.color,
                        sourceAlpha: from.sourceAlpha,
                        destinationAlpha: from.destinationAlpha
                    )
                    sprites.append(sprite)

                    continue
                }

                guard let to else {
                    continue
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

                let sprite = Sprite(
                    uv: uv,
                    xy: xy,
                    textureName: textureName,
                    position: position,
                    angle: angle,
                    color: color,
                    sourceAlpha: from.sourceAlpha,
                    destinationAlpha: from.destinationAlpha
                )
                sprites.append(sprite)
            }

            let frame = Frame(sprites: sprites)
            frames.append(frame)
        }
    }
}

extension Effect {
    public struct Frame {
        public var sprites: [Sprite] = []
    }
}

extension Effect {
    public struct Sprite {
        public var vertices: [EffectVertex] = []
        public var textureName: String

        public var position: SIMD2<Float>
        public var angle: Float
        public var color: SIMD4<Float>
        public var sourceAlpha: Int32
        public var destinationAlpha: Int32

        init(
            uv: SIMD8<Float>,
            xy: SIMD8<Float>,
            textureName: String,
            position: SIMD2<Float>,
            angle: Float,
            color: SIMD4<Float>,
            sourceAlpha: Int32,
            destinationAlpha: Int32
        ) {
            let v0 = EffectVertex(
                position: [xy[0], xy[4]],
                textureCoordinate: [0, 0]   // [uv[0], uv[1]]
            )
            let v1 = EffectVertex(
                position: [xy[1], xy[5]],
                textureCoordinate: [1, 0]   // [uv[2], uv[3]]
            )
            let v2 = EffectVertex(
                position: [xy[3], xy[7]],
                textureCoordinate: [0, 1]   // [uv[4], uv[5]]
            )
            let v3 = EffectVertex(
                position: [xy[2], xy[6]],
                textureCoordinate: [1, 1]   // [uv[6], uv[7]]
            )

            vertices = [v0, v1, v2, v3]

            self.textureName = textureName

            self.position = position
            self.angle = angle
            self.color = color
            self.sourceAlpha = sourceAlpha
            self.destinationAlpha = destinationAlpha
        }
    }
}
