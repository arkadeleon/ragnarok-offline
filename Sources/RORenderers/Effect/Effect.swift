//
//  Effect.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/24.
//

import Metal
import simd
import ROFileFormats
import ROShaders

public struct Effect {
    public var fps: Int
    public var frames: [Frame] = []

    public init(str: STR, textureProvider: (String) -> MTLTexture?) {
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

                let from      = layer.keyframes[fromId]
                let to        = toId > -1 ? layer.keyframes[toId] : nil
                let delta     = frameIndex - from.frameIndex
                let srcalpha  = from.sourceAlpha
                let destalpha = from.destinationAlpha

                guard from.textureIndex > -1 else {
                    continue
                }

                let textureName = layer.textures[Int(from.textureIndex)]
                let texture = textureProvider(textureName)

                // Static frame (or frame that can't be updated)
                if (toId != fromId + 1 || to?.frameIndex != from.frameIndex) {

                    // No other source
                    if (to != nil && lastSource <= from.frameIndex) {
                        continue
                    }

                    let sprite = Sprite(uv: from.uv, xy: from.xy, texture: texture, position: from.position, angle: from.angle, color: from.color)
                    sprites.append(sprite)

                    continue
                }

                guard let to else {
                    continue
                }

                // Morph animation
                let uv = from.uv + to.uv * Float(delta)
                let xy = from.xy + to.uv * Float(delta)
                let position = from.position + to.position * Float(delta)
                let angle = from.angle + to.angle * Float(delta)
                let color = from.color + to.color * Float(delta)

                let sprite = Sprite(uv: uv, xy: xy, texture: texture, position: position, angle: angle, color: color)
                sprites.append(sprite)

//                switch (to.anitype) {
//                    default: // bug fix
//                        result.aniframe = 0;
//                        break;
//
//                    case 1: // normal
//                        result.aniframe = from.aniframe + to.aniframe * delta;
//                        break;
//
//                    case 2: // Stop at end
//                        result.aniframe = Math.min(from.aniframe + to.delay * delta, layer.texcnt - 1);
//                        break;
//
//                    case 3: // Repeat
//                        result.aniframe = (from.aniframe + to.delay * delta) % layer.texcnt;
//                        break;
//
//                    case 4: // play reverse infinitly
//                        result.aniframe = (from.aniframe - to.delay * delta) % layer.texcnt;
//                        break;
//                }
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
        public var texture: MTLTexture?

        public var position: simd_float2
        public var angle: Float
        public var color: simd_float4

        init(uv: simd_float8, xy: simd_float8, texture: MTLTexture?, position: simd_float2, angle: Float, color: simd_float4) {
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

            self.texture = texture

            self.position = position
            self.angle = angle
            self.color = color
        }
    }
}
