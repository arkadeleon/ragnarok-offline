//
//  EffectRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/7/9.
//

import Foundation

public enum EffectRenderResource {
    case `2D`(Effect2DRenderResource)
    case `3D`(Effect3DRenderResource)
    case cylinder(CylinderEffectRenderResource)
    case spr(SPREffectRenderResource)
    case str(STREffectRenderResource)

    public var rendersBeforeEntities: Bool {
        switch self {
        case .`2D`(let resource):
            resource.rendersBeforeEntities
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
        case .`2D`(let resource):
            resource.isExpired(elapsedTime: elapsedTime)
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
