//
//  STREffectRenderResource.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/30.
//

import Foundation
import Metal
import RagnarokRenderAssets
import RagnarokRenderers
import simd

@MainActor
final class STREffectRenderResource {
    let id: UUID
    let creationTime: ContinuousClock.Instant
    let worldPosition: SIMD3<Float>

    private let delay: Duration
    private let spritePosition: SIMD3<Float>
    private let strEffect: STREffect
    private let renderer: STREffectRenderer

    init(
        device: any MTLDevice,
        effect: MetalSkillEffect,
        strEffect: STREffect,
        textures: [String : any MTLTexture],
        worldPosition: SIMD3<Float>
    ) throws {
        self.id = effect.id
        self.creationTime = effect.creationTime
        self.worldPosition = worldPosition
        self.delay = effect.delay
        self.spritePosition = [
            Float(effect.gridPosition.x),
            Float(effect.gridPosition.y),
            worldPosition.y,
        ]
        self.strEffect = strEffect
        self.renderer = try STREffectRenderer(device: device, effect: strEffect, textures: textures)
    }

    func render(
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MetalMapRenderer.RenderMatrices
    ) {
        let elapsed = ContinuousClock.now - creationTime
        guard elapsed >= delay else {
            return
        }

        let effectTime = (elapsed - delay).timeInterval

        renderer.render(
            atTime: effectTime,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: matrices.modelMatrix,
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix,
            spritePosition: spritePosition
        )
    }

    func isExpired(at now: ContinuousClock.Instant) -> Bool {
        guard strEffect.fps > 0, !strEffect.frames.isEmpty else {
            return true
        }

        let duration = TimeInterval(strEffect.frames.count) / TimeInterval(strEffect.fps)
        let elapsed = (now - creationTime - delay).timeInterval
        return elapsed >= duration
    }
}
