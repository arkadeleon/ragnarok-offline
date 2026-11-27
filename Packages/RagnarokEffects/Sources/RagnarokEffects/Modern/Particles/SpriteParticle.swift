//
//  SpriteParticle.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import simd

/// ACT/SPR animated sprite particle rendered through `EffectPrimitiveBatchCollector`.
@MainActor
public final class SpriteParticle {
    public enum LoopMode: Int, Sendable, Equatable {
        case loop = 0
        case oneTime = 1
        case staticFrame = 2
        case manual = 3
    }

    public var effectID: EffectID = .ef_none
    public var actorID: EffectTargetID?
    public var groupIndex: Int = 0
    public var columnIndex: Int = 0
    public var rowIndex: Int = 0

    public var spritePath: String = ""
    public var actionPath: String = ""

    public var position: SIMD3<Float> = .zero
    public var scale: Float = 1.0
    public var angle: Float = 0.0

    public var red: UInt8 = 255
    public var green: UInt8 = 255
    public var blue: UInt8 = 255
    public var alpha: UInt8 = 255

    public var animation: Int = 0
    public var frame: Int = 0
    public var frameDelay: Float = 2.0
    public var elapsedFrames: Int = 0

    /// Lifetime in seconds (`0` = infinite, `< 0` = expired).
    public var life: Float = 0.0
    public var loopMode: LoopMode = .loop

    public var flags: UInt32 = 0
    public var renderOptions: UInt32 = 0
    public var depthOffset: Float = 0.0
    public var screenOffsetX: Float = 0.0
    public var screenOffsetY: Float = 0.0
    public var applyActorExtent: Bool = false
    public var applyActorLift: Bool = false

    public init(position: SIMD3<Float> = .zero, renderOptions: UInt32 = 0) {
        self.position = position
        self.renderOptions = renderOptions
    }

    public var isActive: Bool {
        if life == 0 {
            return true
        }
        return life * 60.0 > Float(elapsedFrames)
    }

    public func setSprite(_ path: String) {
        self.spritePath = path
    }

    public func setAction(_ path: String) {
        self.actionPath = path
    }

    /// Advances the ACT frame index according to `frameDelay` and `loopMode`.
    public func advanceFrame(assets: EffectAssetStore?) {
        guard loopMode != .manual else {
            return
        }
        guard !spritePath.isEmpty, !actionPath.isEmpty,
              let spriteAsset = assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath) else {
            return
        }

        let frameCount = spriteAsset.frameCount(forAction: animation)
        guard frameCount > 0 else {
            return
        }

        let delay = Int(frameDelay)
        if delay == 0 || (elapsedFrames >= delay && elapsedFrames % delay == 0) {
            frame += 1
            if frame >= frameCount {
                switch loopMode {
                case .loop:
                    frame = 0
                case .oneTime:
                    life = -1.0
                    frame = frameCount - 1
                case .staticFrame:
                    frame = frameCount - 1
                case .manual:
                    break
                }
            }
        }
    }

    /// Emits billboard quads for all cells in the current ACT frame.
    public func render(
        into collector: inout EffectPrimitiveBatchCollector,
        assets: EffectAssetStore?
    ) {
        guard isActive,
              !spritePath.isEmpty,
              !actionPath.isEmpty,
              let spriteAsset = assets?.spriteAsset(spritePath: spritePath, actionPath: actionPath),
              let actionFrame = spriteAsset.frame(actionIndex: animation, frameIndex: frame) else {
            return
        }

        let pixelToWorld: Float = 1.0 / 35.0
        let dstBlend: EffectBlendFactor = (flags == 5) ? .one : .oneMinusSourceAlpha
        let renderState = EffectPrimitiveRenderState(
            srcBlend: .sourceAlpha,
            dstBlend: dstBlend,
            depthTest: true,
            depthWrite: false,
            depthBias: depthOffset
        )

        let particleAlpha = Float(alpha) / 255.0
        let particleColor = SIMD4<Float>(
            Float(red) / 255.0,
            Float(green) / 255.0,
            Float(blue) / 255.0,
            particleAlpha
        )
        let usesCellColor = (renderOptions & 0x200) != 0

        for cell in actionFrame.cells {
            guard let spriteImage = spriteAsset.spriteImage(
                spriteType: cell.spriteType,
                spriteIndex: cell.spriteIndex
            ) else {
                continue
            }

            let halfW = Float(spriteImage.width) * 0.5 * cell.scale.x * scale * pixelToWorld
            let halfH = Float(spriteImage.height) * 0.5 * cell.scale.y * scale * pixelToWorld
            let centerX = (cell.offset.x * scale + screenOffsetX) * pixelToWorld
            let centerY = -(cell.offset.y * scale + screenOffsetY) * pixelToWorld

            let radians = -(cell.rotationDegrees + angle) * (.pi / 180.0)
            let c = cosf(radians)
            let s = sinf(radians)
            func corner(_ x: Float, _ y: Float) -> SIMD2<Float> {
                SIMD2<Float>(centerX + x * c - y * s, centerY + x * s + y * c)
            }

            let u0: Float = cell.isMirrored ? 1.0 : 0.0
            let u1: Float = cell.isMirrored ? 0.0 : 1.0

            let finalColor: SIMD4<Float>
            if usesCellColor {
                finalColor = SIMD4<Float>(
                    cell.color.x,
                    cell.color.y,
                    cell.color.z,
                    cell.color.w * particleAlpha
                )
            } else {
                finalColor = particleColor
            }

            collector.appendBillboardQuad(
                anchorEffectPosition: position,
                offset0: corner(-halfW, halfH),
                offset1: corner(halfW, halfH),
                offset2: corner(halfW, -halfH),
                offset3: corner(-halfW, -halfH),
                uv0: SIMD2<Float>(u0, 0),
                uv1: SIMD2<Float>(u1, 0),
                uv2: SIMD2<Float>(u1, 1),
                uv3: SIMD2<Float>(u0, 1),
                color: finalColor,
                texture: spriteImage.texture,
                renderState: renderState
            )
        }
    }
}
