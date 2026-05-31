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
        switch targetPosition &- sourcePosition {
        case [0, -1]:
            self = .south
        case [-1, -1]:
            self = .southwest
        case [-1, 0]:
            self = .west
        case [-1, 1]:
            self = .northwest
        case [0, 1]:
            self = .north
        case [1, 1]:
            self = .northeast
        case [1, 0]:
            self = .east
        case [1, -1]:
            self = .southeast
        default:
            self = .south
        }
    }
}
