//
//  Pathfinder.swift
//  GameCore
//
//  Created by Leon Li on 2025/6/17.
//

import FileFormats
import Foundation

final class Pathfinder {
    let gat: GAT
    let width: Int
    let height: Int

    init(gat: GAT) {
        self.gat = gat
        self.width = Int(gat.width)
        self.height = Int(gat.height)
    }

    func findPath(from start: SIMD2<Int>, to end: SIMD2<Int>) -> [SIMD2<Int>] {
        // Check if start and end positions are valid and walkable
        guard isValidAndWalkable(position: start) && isValidAndWalkable(position: end) else {
            return []
        }

        // If start and end are the same, return single point
        if start == end {
            return [start]
        }

        return astar(from: start, to: end)
    }

    private func astar(from start: SIMD2<Int>, to end: SIMD2<Int>) -> [SIMD2<Int>] {
        var openSet: Set<PathNode> = []    // Nodes to explore
        var closedSet: Set<PathNode> = []  // Nodes already explored
        var allNodes: [SIMD2<Int> : PathNode] = [:]

        let startNode = PathNode(position: start)
        startNode.gScore = 0
        startNode.fScore = heuristic(from: start, to: end)

        openSet.insert(startNode)
        allNodes[start] = startNode

        while !openSet.isEmpty {
            // Find node with lowest fScore (most promising)
            let current = openSet.min { $0.fScore < $1.fScore }!

            // Check if we reached the destination
            if current.position == end {
                return reconstructPath(node: current)
            }

            // Move current from open to closed set
            openSet.remove(current)
            closedSet.insert(current)

            // Check all neighbors
            for neighbor in neighbors(of: current.position) {
                // Skip unwalkable tiles
                if !isValidAndWalkable(position: neighbor) {
                    continue
                }

                // Get or create neighbor node
                let neighborNode = allNodes[neighbor] ?? PathNode(position: neighbor)
                if allNodes[neighbor] == nil {
                    allNodes[neighbor] = neighborNode
                }

                // Skip if already fully explored
                if closedSet.contains(neighborNode) {
                    continue
                }

                // Calculate cost to reach this neighbor through current node
                let tentativeGScore = current.gScore + distance(from: current.position, to: neighbor)

                let isInOpenSet = openSet.contains(neighborNode)
                if !isInOpenSet {
                    // New node to explore
                    openSet.insert(neighborNode)
                } else if tentativeGScore >= neighborNode.gScore {
                    // We already found a better path to this node
                    continue
                }

                // This is the best path to this neighbor so far
                neighborNode.parent = current
                neighborNode.gScore = tentativeGScore
                neighborNode.fScore = tentativeGScore + heuristic(from: neighbor, to: end)
            }
        }

        return [] // No path found
    }

    private func neighbors(of position: SIMD2<Int>) -> [SIMD2<Int>] {
        var neighbors: [SIMD2<Int>] = []

        // 8-directional movement (including diagonals)
        let directions: [SIMD2<Int>] = [
            SIMD2(-1, -1), SIMD2(0, -1), SIMD2(1, -1),  // Top row
            SIMD2(-1,  0),               SIMD2(1,  0),   // Middle row
            SIMD2(-1,  1), SIMD2(0,  1), SIMD2(1,  1)   // Bottom row
        ]

        for direction in directions {
            let neighbor = position &+ direction
            if isInBounds(position: neighbor) {
                neighbors.append(neighbor)
            }
        }

        return neighbors
    }

    private func isInBounds(position: SIMD2<Int>) -> Bool {
        return position.x >= 0 && position.x < width &&
               position.y >= 0 && position.y < height
    }

    private func isValidAndWalkable(position: SIMD2<Int>) -> Bool {
        guard isInBounds(position: position) else {
            return false
        }

        let tile = gat.tileAt(x: position.x, y: position.y)
        return tile.isWalkable
    }

    private func heuristic(from start: SIMD2<Int>, to end: SIMD2<Int>) -> Float {
        // Octile distance (allows diagonal movement)
        let dx = abs(end.x - start.x)
        let dy = abs(end.y - start.y)
        return Float(max(dx, dy)) + Float(min(dx, dy)) * (sqrt(2) - 1)
    }

    private func distance(from start: SIMD2<Int>, to end: SIMD2<Int>) -> Float {
        let dx = end.x - start.x
        let dy = end.y - start.y

        if abs(dx) == 1 && abs(dy) == 1 {
            // Diagonal movement cost
            return sqrt(2)
        } else {
            // Straight movement cost
            return 1
        }
    }

    private func reconstructPath(node: PathNode) -> [SIMD2<Int>] {
        var path: [SIMD2<Int>] = []
        var current: PathNode? = node

        while let currentNode = current {
            path.append(currentNode.position)
            current = currentNode.parent
        }

        return Array(path.reversed())
    }
}

private class PathNode: Equatable, Hashable {
    static func == (lhs: PathNode, rhs: PathNode) -> Bool {
        return lhs.position == rhs.position
    }

    let position: SIMD2<Int>
    var parent: PathNode?
    var gScore: Float = .infinity   // Actual cost from start to this node
    var fScore: Float = .infinity   // gScore + heuristic (estimated total cost)

    init(position: SIMD2<Int>) {
        self.position = position
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
}
