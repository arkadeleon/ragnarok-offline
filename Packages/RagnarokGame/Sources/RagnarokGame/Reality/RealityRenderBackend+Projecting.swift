//
//  RealityRenderBackend+Projecting.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/9.
//

import CoreGraphics
import simd

#if os(iOS) || os(macOS)
extension RealityRenderBackend: GameCoordinateSpaceProjecting {
    func project(_ worldPoint: SIMD3<Float>) -> CGPoint? {
        guard let arView, var screenPoint = arView.project(worldPoint) else {
            return nil
        }

        #if os(macOS)
        screenPoint.y = arView.bounds.height - screenPoint.y
        #endif

        return screenPoint
    }

    func ray(through screenPoint: CGPoint) -> (origin: SIMD3<Float>, direction: SIMD3<Float>)? {
        arView?.ray(through: screenPoint)
    }

    func hitTest(_ screenPoint: CGPoint) -> GameHitTestResult? {
        guard let scene, let arView else {
            return nil
        }

        if let hitEntity = arView.entity(at: screenPoint)?.parent {
            if let object = hitEntity.components[MapSceneObjectComponent.self]?.object {
                return .mapObject(objectID: object.objectID)
            }

            if let item = hitEntity.components[MapSceneItemComponent.self]?.item {
                return .mapItem(objectID: item.objectID)
            }
        }

        guard let (origin, direction) = ray(through: screenPoint) else {
            return nil
        }

        return groundHit(origin: origin, direction: direction, mapGrid: scene.mapGrid)
    }
}
#endif
