//
//  MetalMapScene+Projecting.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/9.
//

import CoreGraphics
import RagnarokRendering
import simd

extension MetalMapScene: GameCoordinateSpaceProjecting {
    public func project(_ worldPoint: SIMD3<Float>) -> CGPoint? {
        guard let camera = renderer.lastCamera else {
            return nil
        }

        let bounds = renderer.lastBounds
        guard bounds.width > 0, bounds.height > 0 else {
            return nil
        }

        let renderPoint = renderer.renderPosition(for: worldPoint)
        let pv = camera.projectionMatrix * camera.viewMatrix
        let clip = pv * SIMD4<Float>(renderPoint, 1)

        guard clip.w > 0 else {
            return nil
        }

        let ndcX = clip.x / clip.w
        let ndcY = clip.y / clip.w

        guard (-1...1).contains(ndcX), (-1...1).contains(ndcY) else {
            return nil
        }

        // NDC → screen coordinates (top-left origin; NDC +Y is up, screen +Y is down).
        let sx = bounds.minX + CGFloat((ndcX + 1) * 0.5) * bounds.width
        let sy = bounds.minY + CGFloat((1 - ndcY) * 0.5) * bounds.height

        return CGPoint(x: sx, y: sy)
    }

    public func ray(through screenPoint: CGPoint) -> (origin: SIMD3<Float>, direction: SIMD3<Float>)? {
        guard let camera = renderer.lastCamera else {
            return nil
        }

        let bounds = renderer.lastBounds
        guard bounds.width > 0, bounds.height > 0 else {
            return nil
        }

        let pv = camera.projectionMatrix * camera.viewMatrix
        let pvInverse = pv.inverse
        if pvInverse[0][0].isNaN {
            return nil
        }

        // Screen (top-left origin) → NDC [-1, 1]; Y is flipped because NDC +Y is up.
        let ndcX = Float((screenPoint.x - bounds.minX) / bounds.width)  * 2 - 1
        let ndcY = 1 - Float((screenPoint.y - bounds.minY) / bounds.height) * 2

        let nearNDC = SIMD4<Float>(ndcX, ndcY, 0, 1)
        let farNDC  = SIMD4<Float>(ndcX, ndcY, 1, 1)

        let nearWorld = pvInverse * nearNDC
        let farWorld  = pvInverse * farNDC

        let nearPos = SIMD3<Float>(nearWorld.x, nearWorld.y, nearWorld.z) / nearWorld.w
        let farPos  = SIMD3<Float>(farWorld.x,  farWorld.y,  farWorld.z)  / farWorld.w

        let direction = simd_normalize(farPos - nearPos)
        return (origin: nearPos, direction: direction)
    }

    public func hitTest(_ screenPoint: CGPoint) -> GameHitTestResult? {
        if let camera = renderer.lastCamera {
            let bounds = renderer.lastBounds
            let hitBoxes = spriteHitBoxes(camera: camera, bounds: bounds)

            for (objectID, rect) in hitBoxes {
                guard rect.contains(screenPoint) else {
                    continue
                }
                if objects[objectID] != nil {
                    return .mapObject(objectID: objectID)
                }
            }
            for (objectID, rect) in hitBoxes {
                guard rect.contains(screenPoint) else {
                    continue
                }
                if items[objectID] != nil {
                    return .mapItem(objectID: objectID)
                }
            }
        }

        guard let (origin, direction) = ray(through: screenPoint) else {
            return nil
        }

        return groundHit(origin: origin, direction: direction, mapGrid: mapGrid)
    }

    private func spriteHitBoxes(
        camera: RenderCamera,
        bounds: CGRect
    ) -> [GameObjectID : CGRect] {
        guard bounds.width > 0, bounds.height > 0 else {
            return [:]
        }

        var hitBoxes: [GameObjectID : CGRect] = [:]
        for drawable in renderer.spriteDrawables {
            guard drawable.isVisible,
                  let rect = spriteHitBox(for: drawable, camera: camera, bounds: bounds) else {
                continue
            }
            if let existing = hitBoxes[drawable.objectID] {
                hitBoxes[drawable.objectID] = existing.union(rect)
            } else {
                hitBoxes[drawable.objectID] = rect
            }
        }

        // Apply minimum hit area: 30pt for items, 60pt for others.
        for (objectID, rect) in hitBoxes {
            let minSize: CGFloat = items[objectID] != nil ? 30 : 60
            var hitBox = rect
            if hitBox.width < minSize {
                hitBox = hitBox.insetBy(dx: (hitBox.width - minSize) / 2, dy: 0)
            }
            if hitBox.height < minSize {
                hitBox = hitBox.insetBy(dx: 0, dy: (hitBox.height - minSize) / 2)
            }
            hitBoxes[objectID] = hitBox
        }

        return hitBoxes
    }

    private func spriteHitBox(
        for drawable: SpriteLayerDrawable,
        camera: RenderCamera,
        bounds: CGRect
    ) -> CGRect? {
        let pv = camera.projectionMatrix * camera.viewMatrix

        let right = SIMD3<Float>(
            camera.viewMatrix[0][0],
            camera.viewMatrix[1][0],
            camera.viewMatrix[2][0]
        )
        let up = SIMD3<Float>(
            camera.viewMatrix[0][1],
            camera.viewMatrix[1][1],
            camera.viewMatrix[2][1]
        )

        let scale: Float = 1.0 / 32.0

        var minSpriteX = Float.infinity
        var minSpriteY = Float.infinity
        var maxSpriteX = -Float.infinity
        var maxSpriteY = -Float.infinity

        for vertex in drawable.vertices {
            minSpriteX = min(minSpriteX, vertex.position.x)
            minSpriteY = min(minSpriteY, vertex.position.y)
            maxSpriteX = max(maxSpriteX, vertex.position.x)
            maxSpriteY = max(maxSpriteY, vertex.position.y)
        }

        guard minSpriteX < maxSpriteX, minSpriteY < maxSpriteY else {
            return nil
        }

        let basePosition = renderer.renderPosition(for: drawable.worldPosition)

        // Project only the top-left and bottom-right corners.
        func projectCorner(_ spriteX: Float, _ spriteY: Float) -> CGPoint? {
            let corner = basePosition + right * spriteX * scale + up * spriteY * scale
            let clip = pv * SIMD4<Float>(corner, 1)
            guard clip.w > 0 else {
                return nil
            }
            let ndcX = clip.x / clip.w
            let ndcY = clip.y / clip.w
            let screenX = bounds.minX + CGFloat((ndcX + 1) * 0.5) * bounds.width
            let screenY = bounds.minY + CGFloat((1 - ndcY) * 0.5) * bounds.height
            return CGPoint(x: screenX, y: screenY)
        }

        guard let topLeft = projectCorner(minSpriteX, maxSpriteY),
              let bottomRight = projectCorner(maxSpriteX, minSpriteY) else {
            return nil
        }

        let x = min(topLeft.x, bottomRight.x)
        let y = min(topLeft.y, bottomRight.y)
        let width = abs(bottomRight.x - topLeft.x)
        let height = abs(bottomRight.y - topLeft.y)

        guard width > 0, height > 0 else {
            return nil
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }
}
