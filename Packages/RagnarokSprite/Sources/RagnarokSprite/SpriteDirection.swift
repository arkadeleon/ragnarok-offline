//
//  SpriteDirection.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2025/5/7.
//

import RagnarokConstants
import simd

public enum SpriteDirection: Int, CaseIterable, CustomStringConvertible, Sendable {
    case south
    case southwest
    case west
    case northwest
    case north
    case northeast
    case east
    case southeast

    public var isDiagonal: Bool {
        switch self {
        case .south, .west, .north, .east:
            false
        case .southwest, .northwest, .northeast, .southeast:
            true
        }
    }

    public var description: String {
        switch self {
        case .south:
            "South"
        case .southwest:
            "Southwest"
        case .west:
            "West"
        case .northwest:
            "Northwest"
        case .north:
            "North"
        case .northeast:
            "Northeast"
        case .east:
            "East"
        case .southeast:
            "Southeast"
        }
    }

    public init(direction: Direction) {
        switch direction {
        case .north:
            self = .north
        case .northwest:
            self = .northwest
        case .west:
            self = .west
        case .southwest:
            self = .southwest
        case .south:
            self = .south
        case .southeast:
            self = .southeast
        case .east:
            self = .east
        case .northeast:
            self = .northeast
        }
    }

    public init(sourcePosition: SIMD2<Int>, targetPosition: SIMD2<Int>) {
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

    public func adjustedForCameraAzimuth(_ azimuth: Float) -> SpriteDirection {
        let offset = Int((-azimuth / (.pi / 4)).rounded())
        let adjusted = ((rawValue + offset) % 8 + 8) % 8
        return SpriteDirection(rawValue: adjusted)!
    }
}
