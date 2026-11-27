//
//  STRParticle.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import RagnarokRendering
import simd

/// STR particle playback instance embedded inside modern `ParticleEffect` subclasses.
@MainActor
public final class STRParticle {
    public var strPath: String = ""
    public var position: SIMD3<Float>
    public var offset: SIMD3<Float> = .zero

    public var scale: Float = 1.0
    public var angle: Float = 0.0
    public var alpha: Float = 1.0
    public var life: Float = 1.0
    public var isLooping: Bool = false
    public var renderMode: STREffectRenderMode = .screen

    public private(set) var playbackState = STREffectPlaybackState()
    private var loadedAsset: STREffectAsset?
    private var currentFrame: STREffectAnimation.Frame?

    public init(position: SIMD3<Float> = .zero) {
        self.position = position
    }

    public func load(_ path: String) {
        strPath = path
        loadedAsset = nil
        currentFrame = nil
        playbackState = STREffectPlaybackState()
        life = 1.0
    }

    public func process(assets: EffectAssetStore?, usesMinimalEffects: Bool = false) {
        guard life >= 0, !strPath.isEmpty else {
            return
        }

        if loadedAsset == nil, let assets {
            if let asset = assets.strAsset(atPath: strPath, usesMinimalEffects: usesMinimalEffects) {
                loadedAsset = asset
            } else if assets.hasFailedSTRAsset(atPath: strPath, usesMinimalEffects: usesMinimalEffects) {
                life = -1.0
                return
            }
        }

        guard let asset = loadedAsset else {
            return
        }

        let str = asset.animation.str
        if playbackState.step(str: str) {
            currentFrame = playbackState.makeFrame(for: str)
        } else if isLooping {
            playbackState.reset(for: str)
            if playbackState.step(str: str) {
                currentFrame = playbackState.makeFrame(for: str)
            }
        } else {
            life = -1.0
            currentFrame = nil
        }
    }

    public func makeRenderPayload(
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext
    ) -> STREffectRenderer.RenderPayload? {
        guard life >= 0,
              let asset = loadedAsset,
              let frame = currentFrame,
              !frame.sprites.isEmpty else {
            return nil
        }

        let worldPosition = EffectSpace.toWorldPosition(position)
        let transform = STREffectTransform(
            scale: scale,
            alpha: alpha,
            angle: angle
        )

        return STREffectRenderer.RenderPayload(
            asset: asset,
            frameIndex: max(0, playbackState.frameCounter - 1),
            frame: frame,
            mode: renderMode,
            worldPosition: worldPosition,
            transform: transform,
            fog: fog,
            modelMatrix: modelMatrix,
            terrainHeight: renderMode == .ground ? { world.worldTerrainHeight(atWorldX: $0, worldZ: $1) } : nil
        )
    }
}
