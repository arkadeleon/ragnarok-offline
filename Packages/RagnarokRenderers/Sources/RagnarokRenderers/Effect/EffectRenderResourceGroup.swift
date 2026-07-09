//
//  EffectRenderResourceGroup.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation
import Metal
import RagnarokRenderAssets
import simd

public final class EffectRenderResourceGroup {
    public let creationTime: TimeInterval
    public let delay: TimeInterval
    public let resources: [EffectRenderResource]

    public var rendersBeforeEntities: Bool {
        resources.contains(where: \.rendersBeforeEntities)
    }

    public init(
        creationTime: TimeInterval,
        delay: TimeInterval,
        resources: [EffectRenderResource]
    ) {
        self.creationTime = creationTime
        self.delay = delay
        self.resources = resources
    }

    public convenience init(
        device: any MTLDevice,
        assetGroup: EffectAssetGroup,
        creationTime: TimeInterval,
        delay: TimeInterval = 0
    ) {
        let resources = assetGroup.assets.flatMap { asset -> [EffectRenderResource] in
            switch asset {
            case .`2D`(let asset):
                var resources: [EffectRenderResource] = []
                let definition = asset.definition
                for duplicateID in 0..<max(definition.duplicate.count, 1) {
                    let resource = Effect2DRenderResource(
                        device: device,
                        asset: asset,
                        duplicateID: duplicateID
                    )
                    resources.append(.`2D`(resource))
                }
                return resources
            case .`3D`(let asset):
                var resources: [EffectRenderResource] = []
                let definition = asset.definition
                for duplicateID in 0..<max(definition.duplicate.count, 1) {
                    let resource = Effect3DRenderResource(
                        device: device,
                        asset: asset,
                        duplicateID: duplicateID
                    )
                    resources.append(.`3D`(resource))
                }
                return resources
            case .cylinder(let asset):
                var resources: [EffectRenderResource] = []
                let definition = asset.definition
                for duplicateID in 0..<max(definition.duplicate.count, 1) {
                    let resource = CylinderEffectRenderResource(
                        device: device,
                        asset: asset,
                        duplicateID: duplicateID
                    )
                    resources.append(.cylinder(resource))
                }
                return resources
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

        self.init(creationTime: creationTime, delay: delay, resources: resources)
    }

    public func isExpired(atTime time: TimeInterval) -> Bool {
        let elapsedTime = time - creationTime - delay
        return !resources.isEmpty && resources.allSatisfy {
            $0.isExpired(elapsedTime: elapsedTime)
        }
    }
}
