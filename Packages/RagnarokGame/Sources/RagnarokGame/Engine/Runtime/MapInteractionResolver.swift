//
//  MapInteractionResolver.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

enum MapMovementDecision {
    case alreadyInRange
    case moveTo(SIMD2<Int>)
    case noPath
}

struct MapInteractionResolver {
    let pathfinder: Pathfinder

    func decideMovement(
        from playerPosition: SIMD2<Int>,
        toward targetPosition: SIMD2<Int>,
        within range: Int
    ) -> MapMovementDecision {
        let path = pathfinder.findPath(from: playerPosition, to: targetPosition, within: range)
        if path.isEmpty {
            return .noPath
        }
        if path == [playerPosition] {
            return .alreadyInRange
        }
        return .moveTo(path.last ?? targetPosition)
    }
}
