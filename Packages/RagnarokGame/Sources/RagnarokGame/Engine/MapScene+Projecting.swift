//
//  MapScene+Projecting.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/9.
//

import CoreGraphics
import RagnarokRendering
import simd

public enum HitTestResult: Sendable {
    case mapObject(objectID: GameObjectID)
    case mapItem(objectID: GameObjectID)
    case ground(position: SIMD2<Int>)
}

extension MapScene {
    /// Searches for objects along a ray through the world.
    public func hitTest(_ ray: Ray) -> HitTestResult? {
        let objectIDs = spriteHits(ray)

        if let objectID = objectIDs.first(where: { objects[$0]?.isDead == false }) {
            return .mapObject(objectID: objectID)
        }
        if let objectID = objectIDs.first(where: { items[$0] != nil }) {
            return .mapItem(objectID: objectID)
        }

        return groundHit(ray, mapGrid: mapGrid)
    }

    private func groundHit(_ ray: Ray, mapGrid: MapGrid) -> HitTestResult? {
        for i in 0..<200 {
            let point = ray.point(atDistance: Float(i))

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

    /// The objects whose sprite the ray passes through, nearest first.
    private func spriteHits(_ ray: Ray) -> [GameObjectID] {
        guard let camera = lastCamera else {
            return []
        }

        // The layers of an object share an anchor, so merge their bounds before hit
        // testing, to grow the object to the minimum tap size once instead of per layer.
        var bounds: [GameObjectID : SpriteBounds] = [:]
        for drawable in renderResources.spriteDrawables where drawable.isVisible {
            guard let layerBounds = spriteBounds(for: drawable) else {
                continue
            }
            bounds[drawable.objectID, default: layerBounds].formUnion(layerBounds)
        }

        var distances: [GameObjectID : Float] = [:]
        for (objectID, objectBounds) in bounds {
            // Items are too small to tap reliably; everything else is already big enough.
            let minimumSize: Float = items[objectID] != nil ? 30 : 0
            guard let distance = hitDistance(ray, bounds: objectBounds, minimumSize: minimumSize, camera: camera) else {
                continue
            }
            distances[objectID] = distance
        }

        return distances.sorted { $0.value < $1.value }.map(\.key)
    }

    private func spriteBounds(for drawable: SpriteLayerDrawable) -> SpriteBounds? {
        var minimum = SIMD2<Float>(repeating: .infinity)
        var maximum = SIMD2<Float>(repeating: -.infinity)

        for vertex in drawable.vertices {
            minimum = simd_min(minimum, vertex.position)
            maximum = simd_max(maximum, vertex.position)
        }

        guard minimum.x < maximum.x, minimum.y < maximum.y else {
            return nil
        }

        return SpriteBounds(
            anchor: MapSceneRenderer.renderPosition(for: drawable.worldPosition),
            minimum: minimum,
            maximum: maximum
        )
    }

    /// The distance along the ray at which it crosses the sprite, if it does at all.
    private func hitDistance(
        _ ray: Ray,
        bounds: SpriteBounds,
        minimumSize: Float,
        camera: RenderCamera
    ) -> Float? {
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
        let backward = SIMD3<Float>(
            camera.viewMatrix[0][2],
            camera.viewMatrix[1][2],
            camera.viewMatrix[2][2]
        )
        let forward = -backward

        // The sprite faces the camera, so cross the ray with the plane it stands on.
        let denominator = simd_dot(ray.direction, forward)
        guard abs(denominator) > .leastNonzeroMagnitude else {
            return nil
        }

        let distance = simd_dot(bounds.anchor - ray.origin, forward) / denominator
        guard distance > 0 else {
            return nil
        }

        let scale: Float = 1.0 / 32.0
        let offset = ray.point(atDistance: distance) - bounds.anchor
        let spritePoint = SIMD2<Float>(simd_dot(offset, right), simd_dot(offset, up)) / scale

        let minimumExtent = ray.pointWidth * distance * minimumSize / 2 / scale
        let extent = simd_max(bounds.extent, SIMD2<Float>(repeating: minimumExtent))

        guard abs(spritePoint.x - bounds.center.x) <= extent.x,
              abs(spritePoint.y - bounds.center.y) <= extent.y else {
            return nil
        }

        return distance
    }
}

/// The bounds of an object's sprite, in sprite space around its world anchor.
private struct SpriteBounds {
    var anchor: SIMD3<Float>
    var minimum: SIMD2<Float>
    var maximum: SIMD2<Float>

    var center: SIMD2<Float> {
        (minimum + maximum) / 2
    }

    var extent: SIMD2<Float> {
        (maximum - minimum) / 2
    }

    mutating func formUnion(_ other: SpriteBounds) {
        minimum = simd_min(minimum, other.minimum)
        maximum = simd_max(maximum, other.maximum)
    }
}
