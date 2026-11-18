//
//  MapGrid.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/10/10.
//

import RagnarokFileFormats
import RagnarokRendering
import simd

struct MapGrid {
    var width: Int
    var height: Int

    struct Cell {
        var bottomLeftAltitude: Float
        var bottomRightAltitude: Float
        var topLeftAltitude: Float
        var topRightAltitude: Float
        var averageAltitude: Float
        var isWalkable: Bool
    }

    private var cells: [MapGrid.Cell] = []

    init(gat: GAT) {
        width = Int(gat.width)
        height = Int(gat.height)

        for y in 0..<height {
            for x in 0..<width {
                let tile = gat.tileAt(x: x, y: y)
                let cell = MapGrid.Cell(
                    bottomLeftAltitude: -tile.bottomLeftAltitude / 5,
                    bottomRightAltitude: -tile.bottomRightAltitude / 5,
                    topLeftAltitude: -tile.topLeftAltitude / 5,
                    topRightAltitude: -tile.topRightAltitude / 5,
                    averageAltitude: -tile.averageAltitude / 5,
                    isWalkable: tile.isWalkable
                )
                cells.append(cell)
            }
        }
    }

    subscript(position: SIMD2<Int>) -> MapGrid.Cell {
        let index = position.x + position.y * width
        return cells[index]
    }

    func contains(_ position: SIMD2<Int>) -> Bool {
        (0..<width).contains(position.x) && (0..<height).contains(position.y)
    }

    func worldPosition(for gridPosition: SIMD2<Int>) -> SIMD3<Float> {
        let altitude = self[gridPosition].averageAltitude
        return [
            Float(gridPosition.x) + 0.5,
            altitude,
            -(Float(gridPosition.y) + 0.5),
        ]
    }

    func worldPosition(at gridPoint: SIMD2<Float>) -> SIMD3<Float> {
        let point = gridPoint + 0.5
        let x = min(max(Int(point.x.rounded(.down)), 0), width - 1)
        let y = min(max(Int(point.y.rounded(.down)), 0), height - 1)
        let fraction = simd_clamp(point - SIMD2<Float>(Float(x), Float(y)), .zero, .one)

        let cell = self[SIMD2(x, y)]
        let bottomAltitude = cell.bottomLeftAltitude + (cell.bottomRightAltitude - cell.bottomLeftAltitude) * fraction.x
        let topAltitude = cell.topLeftAltitude + (cell.topRightAltitude - cell.topLeftAltitude) * fraction.x
        let altitude = bottomAltitude + (topAltitude - bottomAltitude) * fraction.y

        return [
            point.x,
            altitude,
            -point.y,
        ]
    }

    /// Returns the Y-up world position (`+X` east, `+Y` up, `-Z` north) for a GAT cell and 1/16 subcell.
    func subcellWorldPosition(column: Int, row: Int, subColumn: Int = 8, subRow: Int = 8) -> SIMD3<Float> {
        let worldX = Float(column) + Float(subColumn) * 0.0625
        let worldZ = -(Float(row) + Float(subRow) * 0.0625)
        let worldY = height(atWorldX: worldX, worldZ: worldZ)
        return [worldX, worldY, worldZ]
    }

    /// Returns the terrain height (`+Y` up) at a Y-up world XZ coordinate using the cell's two-triangle surface.
    func height(atWorldX worldX: Float, worldZ: Float) -> Float {
        guard width > 0, height > 0 else {
            return 0
        }

        let gridX = worldX
        let gridY = -worldZ

        let column = min(max(Int(floor(gridX)), 0), width - 1)
        let row = min(max(Int(floor(gridY)), 0), height - 1)
        let u = simd_clamp(gridX - Float(column), 0, 1)
        let v = simd_clamp(gridY - Float(row), 0, 1)

        let cell = self[SIMD2(column, row)]
        if v <= u {
            return cell.bottomLeftAltitude
                + (cell.bottomRightAltitude - cell.bottomLeftAltitude) * u
                + (cell.topRightAltitude - cell.bottomRightAltitude) * v
        } else {
            return cell.bottomLeftAltitude
                + (cell.topRightAltitude - cell.topLeftAltitude) * u
                + (cell.topLeftAltitude - cell.bottomLeftAltitude) * v
        }
    }

    /// Intersects a Y-up world-space ray with the terrain grid using 2D DDA traversal and Möller–Trumbore triangle tests.
    func rayHit(_ ray: Ray, maxDistance: Float = 500) -> SIMD2<Int>? {
        guard width > 0, height > 0 else {
            return nil
        }

        let originX = ray.origin.x
        let originY = -ray.origin.z
        let directionX = ray.direction.x
        let directionY = -ray.direction.z

        // Clip the ray against the map's 2D XZ bounds [0, width] x [0, height].
        var startDistance: Float = 0
        var endDistance: Float = maxDistance

        guard let (minimumDistanceX, maximumDistanceX) = slabInterval(origin: originX, direction: directionX, minimumBound: 0, maximumBound: Float(width)),
              let (minimumDistanceY, maximumDistanceY) = slabInterval(origin: originY, direction: directionY, minimumBound: 0, maximumBound: Float(height)) else {
            return nil
        }

        startDistance = max(startDistance, max(minimumDistanceX, minimumDistanceY))
        endDistance = min(endDistance, min(maximumDistanceX, maximumDistanceY))

        guard startDistance <= endDistance else {
            return nil
        }

        let startX = originX + directionX * startDistance
        let startY = originY + directionY * startDistance

        var column = min(max(Int(floor(startX)), 0), width - 1)
        var row = min(max(Int(floor(startY)), 0), height - 1)

        let stepX = directionX > 0 ? 1 : (directionX < 0 ? -1 : 0)
        let stepY = directionY > 0 ? 1 : (directionY < 0 ? -1 : 0)

        let deltaDistanceX = directionX != 0 ? abs(1 / directionX) : .infinity
        let deltaDistanceY = directionY != 0 ? abs(1 / directionY) : .infinity

        var nextBoundaryDistanceX: Float = if directionX > 0 {
            startDistance + (Float(column + 1) - startX) / directionX
        } else if directionX < 0 {
            startDistance + (Float(column) - startX) / directionX
        } else {
            .infinity
        }

        var nextBoundaryDistanceY: Float = if directionY > 0 {
            startDistance + (Float(row + 1) - startY) / directionY
        } else if directionY < 0 {
            startDistance + (Float(row) - startY) / directionY
        } else {
            .infinity
        }

        while (0..<width).contains(column) && (0..<height).contains(row) {
            let cell = self[SIMD2(column, row)]
            let x0 = Float(column)
            let x1 = Float(column + 1)
            let z0 = -Float(row)
            let z1 = -Float(row + 1)

            let v0 = SIMD3<Float>(x0, cell.bottomLeftAltitude, z0)
            let v1 = SIMD3<Float>(x1, cell.bottomRightAltitude, z0)
            let v2 = SIMD3<Float>(x1, cell.topRightAltitude, z1)
            let v3 = SIMD3<Float>(x0, cell.topLeftAltitude, z1)

            if let distance = intersectRayTriangle(ray: ray, v0: v0, v1: v1, v2: v2), distance <= maxDistance {
                return SIMD2(column, row)
            }
            if let distance = intersectRayTriangle(ray: ray, v0: v2, v1: v3, v2: v0), distance <= maxDistance {
                return SIMD2(column, row)
            }

            if min(nextBoundaryDistanceX, nextBoundaryDistanceY) > endDistance {
                break
            }

            if nextBoundaryDistanceX < nextBoundaryDistanceY {
                nextBoundaryDistanceX += deltaDistanceX
                column += stepX
            } else {
                nextBoundaryDistanceY += deltaDistanceY
                row += stepY
            }
        }

        return nil
    }

    private func slabInterval(origin: Float, direction: Float, minimumBound: Float, maximumBound: Float) -> (Float, Float)? {
        if abs(direction) < 1e-8 {
            return (origin >= minimumBound && origin <= maximumBound) ? (-.infinity, .infinity) : nil
        }
        let inverseDirection = 1 / direction
        let t1 = (minimumBound - origin) * inverseDirection
        let t2 = (maximumBound - origin) * inverseDirection
        return (min(t1, t2), max(t1, t2))
    }

    private func intersectRayTriangle(ray: Ray, v0: SIMD3<Float>, v1: SIMD3<Float>, v2: SIMD3<Float>) -> Float? {
        let edge1 = v1 - v0
        let edge2 = v2 - v0
        let directionCrossEdge2 = simd_cross(ray.direction, edge2)
        let determinant = simd_dot(edge1, directionCrossEdge2)

        if abs(determinant) < 1e-7 {
            return nil
        }

        let inverseDeterminant = 1 / determinant
        let originOffset = ray.origin - v0
        let u = simd_dot(originOffset, directionCrossEdge2) * inverseDeterminant
        if u < -1e-5 || u > 1 + 1e-5 {
            return nil
        }

        let offsetCrossEdge1 = simd_cross(originOffset, edge1)
        let v = simd_dot(ray.direction, offsetCrossEdge1) * inverseDeterminant
        if v < -1e-5 || u + v > 1 + 1e-5 {
            return nil
        }

        let distance = simd_dot(edge2, offsetCrossEdge1) * inverseDeterminant
        return distance >= 0 ? distance : nil
    }
}
