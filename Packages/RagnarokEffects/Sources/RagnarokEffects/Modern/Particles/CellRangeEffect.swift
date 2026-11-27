//
//  CellRangeEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import RagnarokRendering
import simd

/// Grid-cell ground effect spawning a `(2*range+1) x (2*range+1)` lattice of terrain-snapped particles.
@MainActor
public final class CellRangeEffect: ParticleEffect {
    public var cellSize: Float = 5.0
    public var gridRange: Int = 1
    public private(set) var particles: [Particle] = []

    public required init(id: UUID = UUID(), request: EffectSpawnRequest) {
        super.init(id: id, request: request)
        if let firstParam = request.parameters.first, firstParam >= 0 {
            gridRange = Int(firstParam)
        }
    }

    public override func open(context: EffectTickContext) {
        let clampedRange = max(0, min(gridRange, 10))
        for row in -clampedRange...clampedRange {
            for column in -clampedRange...clampedRange {
                let particle = Particle(position: position)
                particle.active = true
                particle.effectID = effectID
                particle.groupIndex = 1
                particle.columnIndex = column
                particle.rowIndex = row
                particle.alpha = 255
                particle.setColor(255, 255, 255)
                particle.setTexture("effect\\torch_violet08.bmp")
                particle.scale = 8.0
                particles.append(particle)
            }
        }
    }

    public override func close() {
        particles.removeAll()
    }

    public override func onProcess(context: EffectTickContext) {
        for particle in particles {
            updateParticle(particle, world: context.world)
            applyCellTexture(particle)
            particle.elapsedFrames += 1
        }
    }

    public override func collectParticles(
        into collector: inout EffectPrimitiveBatchCollector,
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext,
        assets: EffectAssetStore?
    ) {
        for particle in particles {
            particle.render(
                into: &collector,
                world: world,
                assets: assets,
                usesTransformDirectly: false,
                depthTest: true
            )
        }
    }

    private func updateParticle(_ particle: Particle, world: any EffectWorldContext) {
        let cellX = position.x + Float(particle.columnIndex) * cellSize
        let cellZ = position.z + Float(particle.rowIndex) * cellSize
        let cellY = world.terrainHeight(atEffectX: cellX, effectZ: cellZ) - 1.2
        particle.position = SIMD3<Float>(cellX, cellY, cellZ)

        let pitchRadians = world.cameraPitchDegrees / 180.0 * EffectSpace.clientPi
        let rotation = EffectSpace.rotationX(radians: pitchRadians + EffectSpace.clientPi)
        let scale = ParticleMath.makeScaleMatrix(particle.scale, particle.scale, 1.0)
        particle.transform = rotation * scale
    }

    private func applyCellTexture(_ particle: Particle) {
        let frameIndex = ((particle.elapsedFrames + particle.columnIndex) / 10) % 3 + 1
        let clampedFrame = frameIndex <= 0 ? frameIndex + 3 : frameIndex

        switch effectID {
        case .ef_ko_zenkai_water:
            particle.setTexture("effect\\water-\(clampedFrame).bmp")
        case .ef_ko_zenkai_land:
            particle.setTexture("effect\\stone-\(clampedFrame).bmp")
        case .ef_ko_zenkai_fire:
            particle.setTexture("effect\\fire-\(clampedFrame).bmp")
        case .ef_ko_zenkai_wind:
            particle.setTexture("effect\\lightning-\(clampedFrame).bmp")
        case .ef_ko_makibishi:
            particle.setTexture("effect\\makibishi.bmp")
            particle.scale = 2.5
            particle.destinationBlend = EffectBlendFactor.oneMinusSourceAlpha.rawValue
        default:
            break
        }
    }
}
