//
//  EffectRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation
import Metal
import RagnarokRenderAssets
import simd

public final class EffectRenderResource {
    public let creationTime: TimeInterval
    public let delay: TimeInterval
    public let components: [EffectRenderResourceComponent]

    public var rendersBeforeEntities: Bool {
        components.contains(where: \.rendersBeforeEntities)
    }

    public init(
        creationTime: TimeInterval,
        delay: TimeInterval,
        components: [EffectRenderResourceComponent]
    ) {
        self.creationTime = creationTime
        self.delay = delay
        self.components = components
    }

    public convenience init(
        device: any MTLDevice,
        asset: EffectAsset,
        worldPosition: SIMD3<Float>,
        spritePosition: SIMD3<Float>,
        creationTime: TimeInterval,
        delay: TimeInterval = 0
    ) {
        let components = asset.components.flatMap { component -> [EffectRenderResourceComponent] in
            switch component {
            case .`3D`(let asset):
                var components: [EffectRenderResourceComponent] = []
                let definition = asset.definition
                for duplicateID in 0..<max(definition.duplicate.count, 1) {
                    let resource = Effect3DRenderResource(
                        device: device,
                        asset: asset,
                        worldPosition: worldPosition,
                        duplicateID: duplicateID
                    )
                    components.append(.`3D`(resource))
                }
                return components
            case .cylinder(let asset):
                var components: [EffectRenderResourceComponent] = []
                let definition = asset.definition
                for duplicateID in 0..<max(definition.duplicate.count, 1) {
                    let resource = CylinderEffectRenderResource(
                        device: device,
                        asset: asset,
                        worldPosition: worldPosition,
                        duplicateID: duplicateID
                    )
                    components.append(.cylinder(resource))
                }
                return components
            case .spr(let asset):
                var worldPosition = worldPosition
                if asset.definition.rendersAtHead {
                    worldPosition.y += 2.5
                }
                let resource = SPREffectRenderResource(
                    device: device,
                    asset: asset,
                    worldPosition: worldPosition
                )
                return [.spr(resource)]
            case .str(let asset):
                let resource = STREffectRenderResource(
                    device: device,
                    asset: asset,
                    spritePosition: spritePosition
                )
                return [.str(resource)]
            }
        }

        self.init(creationTime: creationTime, delay: delay, components: components)
    }

    public func isExpired(atTime time: TimeInterval) -> Bool {
        let elapsedTime = time - creationTime - delay
        return !components.isEmpty && components.allSatisfy {
            $0.isExpired(elapsedTime: elapsedTime)
        }
    }
}

public enum EffectRenderResourceComponent {
    case `3D`(Effect3DRenderResource)
    case cylinder(CylinderEffectRenderResource)
    case spr(SPREffectRenderResource)
    case str(STREffectRenderResource)

    public var rendersBeforeEntities: Bool {
        switch self {
        case .`3D`(let resource):
            resource.rendersBeforeEntities
        case .cylinder(let resource):
            resource.rendersBeforeEntities
        case .spr(let resource):
            resource.rendersBeforeEntities
        case .str:
            false
        }
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        switch self {
        case .`3D`(let resource):
            resource.isExpired(elapsedTime: elapsedTime)
        case .cylinder(let resource):
            resource.isExpired(elapsedTime: elapsedTime)
        case .spr(let resource):
            resource.isExpired(elapsedTime: elapsedTime)
        case .str(let resource):
            resource.isExpired(elapsedTime: elapsedTime)
        }
    }
}
