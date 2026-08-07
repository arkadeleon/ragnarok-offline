//
//  SpriteDirection+Movement.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RagnarokSprite
import simd

extension SpriteDirection {
    init(sourcePosition: SIMD2<Int>, targetPosition: SIMD2<Int>) {
        let delta = targetPosition &- sourcePosition
        guard delta != .zero else {
            self = .south
            return
        }

        let angle = atan2(Float(delta.y), Float(delta.x))
        let octant = Int((angle / (.pi / 4)).rounded())
        let normalizedOctant = ((octant % 8) + 8) % 8

        switch normalizedOctant {
        case 0:
            self = .east
        case 1:
            self = .northeast
        case 2:
            self = .north
        case 3:
            self = .northwest
        case 4:
            self = .west
        case 5:
            self = .southwest
        case 6:
            self = .south
        default:
            self = .southeast
        }
    }
}
