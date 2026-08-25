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

    public var rendersBeforeEntities: Bool {
        resources.contains(where: \.rendersBeforeEntities)
    }

    public init(
        creationTime: TimeInterval,
        delay: TimeInterval,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>? = nil,
        resources: [EffectRenderResource]
    ) {
        self.creationTime = creationTime
        self.delay = delay
        self.worldPosition = worldPosition
        self.sourceWorldPosition = sourceWorldPosition
        self.resources = resources
    }

    public convenience init(
        device: any MTLDevice,
        assetGroup: EffectAssetGroup,
        creationTime: TimeInterval,
        delay: TimeInterval = 0,
        worldPosition: SIMD3<Float> = .zero,
        sourceWorldPosition: SIMD3<Float>? = nil
    ) {
        let resources = assetGroup.assets.flatMap { asset -> [EffectRenderResource] in
            switch asset {
            case .`2D`(let asset):
                return asset.makeInstances().map { instance in
                    let resource = TwoDEffectRenderResource(
                        device: device,
                        asset: asset,
                        instance: instance
                    )
                    return .`2D`(resource)
                }
            case .`3D`(let asset):
                return asset.makeInstances().map { instance in
                    let resource = ThreeDEffectRenderResource(
                        device: device,
                        asset: asset,
                        instance: instance
                    )
                    return .`3D`(resource)
                }
            case .cylinder(let asset):
                return asset.makeInstances().map { instance in
                    let resource = CylinderEffectRenderResource(
                        device: device,
                        asset: asset,
                        instance: instance
                    )
                    return .cylinder(resource)
                }
            case .spr(let asset):
                let resource = SPREffectRenderResource(
                    device: device,
                    asset: asset
                )
                return [.spr(resource)]
            case .str(let asset):
                let resource = STREffectRenderResource(
                    device: device,
                    asset: asset
                )
                return [.str(resource)]
            }
        }

        self.init(
            creationTime: creationTime,
            delay: delay,
            worldPosition: worldPosition,
            sourceWorldPosition: sourceWorldPosition,
            resources: resources
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
