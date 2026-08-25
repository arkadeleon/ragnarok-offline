//
//  EffectRenderResourceGroup.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation
import Metal
import RagnarokRenderAssets
import simd

public final class EffectRenderResourceGroup {
    public private(set) var creationTime: TimeInterval
    public let delay: TimeInterval
    public let worldPosition: SIMD3<Float>
    public let sourceWorldPosition: SIMD3<Float>?
    public let resources: [EffectRenderResource]
    public let sounds: [EffectSound]

    public var rendersBeforeEntities: Bool {
        resources.contains(where: \.rendersBeforeEntities)
    }

    public init(
        creationTime: TimeInterval,
        delay: TimeInterval,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>? = nil,
        resources: [EffectRenderResource],
        sounds: [EffectSound]
    ) {
        self.creationTime = creationTime
        self.delay = delay
        self.worldPosition = worldPosition
        self.sourceWorldPosition = sourceWorldPosition
        self.resources = resources
        self.sounds = sounds
    }

    public convenience init(
        device: any MTLDevice,
        assetGroup: EffectAssetGroup,
        creationTime: TimeInterval,
        delay: TimeInterval = 0,
        worldPosition: SIMD3<Float> = .zero,
        sourceWorldPosition: SIMD3<Float>? = nil
    ) {
        var resources: [EffectRenderResource] = []
        var sounds: [EffectSound] = []

        for asset in assetGroup.assets {
            switch asset {
            case .`2D`(let asset):
                let instances = asset.makeInstances()
                for instance in instances {
                    let resource = TwoDEffectRenderResource(
                        device: device,
                        asset: asset,
                        instance: instance
                    )
                    resources.append(.`2D`(resource))

                    if let sound = instance.sound {
                        sounds.append(sound)
                    }
                }
            case .`3D`(let asset):
                let instances = asset.makeInstances()
                for instance in instances {
                    let resource = ThreeDEffectRenderResource(
                        device: device,
                        asset: asset,
                        instance: instance
                    )
                    resources.append(.`3D`(resource))

                    if let sound = instance.sound {
                        sounds.append(sound)
                    }
                }
            case .cylinder(let asset):
                let instances = asset.makeInstances()
                for instance in instances {
                    let resource = CylinderEffectRenderResource(
                        device: device,
                        asset: asset,
                        instance: instance
                    )
                    resources.append(.cylinder(resource))

                    if let sound = instance.sound {
                        sounds.append(sound)
                    }
                }
            case .spr(let asset):
                let resource = SPREffectRenderResource(
                    device: device,
                    asset: asset
                )
                resources.append(.spr(resource))

                if let sound = asset.sound {
                    sounds.append(sound)
                }
            case .str(let asset):
                let resource = STREffectRenderResource(
                    device: device,
                    asset: asset
                )
                resources.append(.str(resource))

                if let sound = asset.sound {
                    sounds.append(sound)
                }
            case .wav(let asset):
                sounds.append(asset.sound)
            }
        }

        self.init(
            creationTime: creationTime,
            delay: delay,
            worldPosition: worldPosition,
            sourceWorldPosition: sourceWorldPosition,
            resources: resources,
            sounds: sounds
        )
    }

    public func restart(atTime time: TimeInterval) {
        creationTime = time
    }

    public func isExpired(atTime time: TimeInterval) -> Bool {
        let elapsedTime = time - creationTime - delay
        return !resources.isEmpty && resources.allSatisfy {
            $0.isExpired(elapsedTime: elapsedTime)
        }
    }
}
