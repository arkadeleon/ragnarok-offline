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
            if let mapObject = hitEntity.components[MapObjectComponent.self]?.mapObject {
                return .mapObject(objectID: mapObject.objectID)
            }

            if let mapItem = hitEntity.components[MapItemComponent.self]?.mapItem {
                return .item(objectID: mapItem.objectID)
            }
        }

        guard let (origin, direction) = ray(through: screenPoint) else {
            return nil
        }

        return groundHit(origin: origin, direction: direction, mapGrid: scene.mapGrid)
    }

    private func groundHit(
        origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        mapGrid: MapGrid
    ) -> GameHitTestResult? {
        for i in 0..<200 {
            let point = origin + direction * Float(i)

            let x = point.x
            let y = -point.z
            let position = SIMD2<Int>(Int(x), Int(y))

            guard mapGrid.contains(position) else {
                continue
            }

            let cell = mapGrid[position]
            let xr = x.truncatingRemainder(dividingBy: 1)
            let yr = y.truncatingRemainder(dividingBy: 1)

            let x1 = cell.bottomLeftAltitude + (cell.bottomRightAltitude - cell.bottomLeftAltitude) * xr
            let x2 = cell.topLeftAltitude + (cell.topRightAltitude - cell.topLeftAltitude) * xr
            let altitude = x1 + (x2 - x1) * yr

            if fabsf(altitude - point.y) < 0.5 {
                return .ground(position: position)
            }
        }

        return nil
    }
}
#endif
