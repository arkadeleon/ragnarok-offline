//
//  EffectRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation

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

    public func isExpired(atTime time: TimeInterval) -> Bool {
        !components.isEmpty && components.allSatisfy {
            $0.isExpired(atTime: time)
        }
    }
}

public enum EffectRenderResourceComponent {
    case `3D`(Effect3DRenderResource)
    case cylinder(CylinderEffectRenderResource)
    case spr(SPREffectRenderResource)
    case str(STREffectRenderResource)

    public var creationTime: TimeInterval {
        switch self {
        case .`3D`(let resource):
            resource.creationTime
        case .cylinder(let resource):
            resource.creationTime
        case .spr(let resource):
            resource.creationTime
        case .str(let resource):
            resource.creationTime
        }
    }

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

    public func isExpired(atTime time: TimeInterval) -> Bool {
        switch self {
        case .`3D`(let resource):
            resource.isExpired(atTime: time)
        case .cylinder(let resource):
            resource.isExpired(atTime: time)
        case .spr(let resource):
            resource.isExpired(atTime: time)
        case .str(let resource):
            resource.isExpired(atTime: time)
        }
    }
}
