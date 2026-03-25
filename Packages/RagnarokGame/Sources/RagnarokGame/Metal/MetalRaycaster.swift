//
//  MetalRaycaster.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import CoreGraphics
import simd

enum MetalRaycaster {
    /// Un-projects a screen point (top-left origin) through (P × V)^{-1} to a world-space ray.
    static func ray(
        through screenPoint: CGPoint,
        viewport: CGRect,
        matrices: MapRuntimeRenderer.RenderMatrices
    ) -> (origin: SIMD3<Float>, direction: SIMD3<Float>)? {
        guard viewport.width > 0, viewport.height > 0 else {
            return nil
        }

        let pv = matrices.projectionMatrix * matrices.viewMatrix
        let pvInverse = pv.inverse
        if pvInverse[0][0].isNaN {
            return nil
        }

        // Screen (top-left origin) → NDC [-1, 1]; Y is flipped because NDC +Y is up.
        let ndcX = Float((screenPoint.x - viewport.minX) / viewport.width)  * 2 - 1
        let ndcY = 1 - Float((screenPoint.y - viewport.minY) / viewport.height) * 2

        let nearNDC = SIMD4<Float>(ndcX, ndcY, 0, 1)
        let farNDC  = SIMD4<Float>(ndcX, ndcY, 1, 1)

        let nearWorld = pvInverse * nearNDC
        let farWorld  = pvInverse * farNDC

        let nearPos = SIMD3<Float>(nearWorld.x, nearWorld.y, nearWorld.z) / nearWorld.w
        let farPos  = SIMD3<Float>(farWorld.x,  farWorld.y,  farWorld.z)  / farWorld.w

        let direction = simd_normalize(farPos - nearPos)
        return (origin: nearPos, direction: direction)
    }

    static func groundHit(
        origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        mapGrid: MapGrid
    ) -> MapHitTestResult? {
        for i in 0..<200 {
            let point = origin + direction * Float(i)

            let x = point.x
            let y = -point.z
            let position = SIMD2<Int>(Int(x), Int(y))

            guard 0..<mapGrid.width ~= position.x, 0..<mapGrid.height ~= position.y else {
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
