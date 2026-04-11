//
//  MetalRenderBackend+Projecting.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/9.
//

import CoreGraphics
import simd

extension MetalRenderBackend: GameCoordinateSpaceProjecting {
    func project(_ worldPoint: SIMD3<Float>) -> CGPoint? {
        guard let matrices = renderer.lastRenderMatrices else {
            return nil
        }

        let viewport = renderer.lastViewport
        guard viewport.width > 0, viewport.height > 0 else {
            return nil
        }

        // worldPoint is already in world space; apply P × V only, no model matrix.
        let pv = matrices.projectionMatrix * matrices.viewMatrix
        let clip = pv * SIMD4<Float>(worldPoint.x, worldPoint.y, worldPoint.z, 1)

        guard clip.w > 0 else {
            return nil
        }

        let ndcX = clip.x / clip.w
        let ndcY = clip.y / clip.w

        guard (-1...1).contains(ndcX), (-1...1).contains(ndcY) else {
            return nil
        }

        // NDC → screen coordinates (top-left origin; NDC +Y is up, screen +Y is down).
        let sx = viewport.minX + CGFloat((ndcX + 1) * 0.5) * viewport.width
        let sy = viewport.minY + CGFloat((1 - ndcY) * 0.5) * viewport.height

        return CGPoint(x: sx, y: sy)
    }

    func ray(through screenPoint: CGPoint) -> (origin: SIMD3<Float>, direction: SIMD3<Float>)? {
        guard let matrices = renderer.lastRenderMatrices else {
            return nil
        }

        let viewport = renderer.lastViewport
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

    func hitTest(_ screenPoint: CGPoint) -> GameHitTestResult? {
        guard let scene else {
            return nil
        }

        if let matrices = renderer.lastRenderMatrices {
            let viewport = renderer.lastViewport
            let hitBoxes = spriteHitBoxes(matrices: matrices, viewport: viewport)

            for (objectID, rect) in hitBoxes {
                guard rect.contains(screenPoint) else {
                    continue
                }
                if scene.state.objects[objectID] != nil || objectID == scene.state.player.id {
                    return .mapObject(objectID: objectID)
                }
            }
            for (objectID, rect) in hitBoxes {
                guard rect.contains(screenPoint) else {
                    continue
                }
                if scene.state.items[objectID] != nil {
                    return .item(objectID: objectID)
                }
            }
        }

        guard let (origin, direction) = ray(through: screenPoint) else {
            return nil
        }

        return groundHit(origin: origin, direction: direction, mapGrid: scene.mapGrid)
    }

    private func spriteHitBoxes(
        matrices: MapRuntimeRenderer.RenderMatrices,
        viewport: CGRect
    ) -> [GameObjectID : CGRect] {
        guard viewport.width > 0, viewport.height > 0 else {
            return [:]
        }

        var hitBoxes: [GameObjectID : CGRect] = [:]
        for (objectID, drawable) in renderer.spriteDrawables {
            guard drawable.isVisible,
                  let rect = spriteHitBox(for: drawable, matrices: matrices, viewport: viewport) else {
                continue
            }
            hitBoxes[objectID] = rect
        }
        return hitBoxes
    }

    private func spriteHitBox(
        for drawable: SpriteDrawable,
        matrices: MapRuntimeRenderer.RenderMatrices,
        viewport: CGRect
    ) -> CGRect? {
        let pv = matrices.projectionMatrix * matrices.viewMatrix

        let right = SIMD3<Float>(
            matrices.viewMatrix[0][0],
            matrices.viewMatrix[1][0],
            matrices.viewMatrix[2][0]
        )
        let up = SIMD3<Float>(
            matrices.viewMatrix[0][1],
            matrices.viewMatrix[1][1],
            matrices.viewMatrix[2][1]
        )

        let halfWidth = drawable.frameWidth / 2
        let height = drawable.frameHeight
        let scale: Float = 1.0 / 32.0

        let corners: [SIMD3<Float>] = [
            drawable.worldPosition + (-right * halfWidth) * scale,
            drawable.worldPosition + (right * halfWidth) * scale,
            drawable.worldPosition + (-right * halfWidth + up * height) * scale,
            drawable.worldPosition + (right * halfWidth + up * height) * scale,
        ]

        var minX = CGFloat.infinity
        var minY = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var maxY = -CGFloat.infinity

        for corner in corners {
            let clip = pv * SIMD4<Float>(corner, 1)
            guard clip.w > 0 else {
                return nil
            }

            let ndcX = clip.x / clip.w
            let ndcY = clip.y / clip.w

            let screenX = viewport.minX + CGFloat((ndcX + 1) * 0.5) * viewport.width
            let screenY = viewport.minY + CGFloat((1 - ndcY) * 0.5) * viewport.height

            minX = min(minX, screenX)
            minY = min(minY, screenY)
            maxX = max(maxX, screenX)
            maxY = max(maxY, screenY)
        }

        guard minX < maxX, minY < maxY else {
            return nil
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    func groundHit(
        origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        mapGrid: MapGrid
    ) -> GameHitTestResult? {
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
