//
//  ComposedSprite.Direction.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/7.
//

extension ComposedSprite {
    public enum Direction: Int, CaseIterable, CustomStringConvertible, Sendable {
        case south
        case southwest
        case west
        case northwest
        case north
        case northeast
        case east
        case southeast

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
    }
}
