//
//  CharacterDirection.swift
//  SpriteRendering
//
//  Created by Leon Li on 2025/5/7.
//

import Constants

public enum CharacterDirection: Int, CaseIterable, CustomStringConvertible, Sendable {
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
}
