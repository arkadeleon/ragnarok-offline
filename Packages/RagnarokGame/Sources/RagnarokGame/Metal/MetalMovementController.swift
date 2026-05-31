//
//  MetalMovementController.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import simd

@MainActor
public final class MetalMovementController {
    private let pathFinder: PathFinder
    private let mapGrid: MapGrid

    public private(set) var movement: MetalMovement?

    init(pathFinder: PathFinder, mapGrid: MapGrid) {
        self.pathFinder = pathFinder
        self.mapGrid = mapGrid
    }

    @discardableResult
    func replan(
        startPosition: SIMD2<Int>,
        endPosition: SIMD2<Int>,
        speed: Int,
        at time: ContinuousClock.Instant = .now
    ) -> MetalMovement {
        let planner = MetalMovementPlanner(pathFinder: pathFinder)
        var planned = planner.replan(
            existingMovement: movement,
            incomingStartPosition: startPosition,
            incomingEndPosition: endPosition,
            speed: speed,
            at: time
        )
        planned.updateWorldPath { mapGrid.worldPosition(for: $0) }
        planned.update(atTime: time)
        movement = planned
        return planned
    }

    func stop() {
        movement = nil
    }

    func update(at time: ContinuousClock.Instant) {
        guard var current = movement else {
            return
        }
        current.update(atTime: time)
        movement = current
    }

    func nextPosition(at time: ContinuousClock.Instant) -> SIMD2<Int>? {
        movement?.nextPosition(at: time)
    }
}
