//
//  SpriteActionType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/5/6.
//

public enum SpriteActionType: String, CaseIterable, CustomStringConvertible, Sendable {
    case idle
    case walk
    case sit
    case pickup
    case attackWait
    case attack
    case hurt
    case freeze
    case die
    case freeze2
    case attack2
    case attack3
    case skill

    public var description: String {
        switch self {
        case .idle:
            "Idle"
        case .walk:
            "Walk"
        case .sit:
            "Sit"
        case .pickup:
            "Pickup"
        case .attackWait:
            "Attack Wait"
        case .attack:
            "Attack"
        case .hurt:
            "Hurt"
        case .freeze:
            "Freeze"
        case .die:
            "Die"
        case .freeze2:
            "Freeze"
        case .attack2:
            "Attack"
        case .attack3:
            "Attack"
        case .skill:
            "Skill"
        }
    }
}

extension SpriteActionType {
    public static func availableActionTypes(forJobID jobID: Int) -> [SpriteActionType] {
        let job = UniformJob(rawValue: jobID)

        if job.isPlayer {
            return [.idle, .walk, .sit, .pickup, .attackWait, .attack, .hurt, .freeze, .die, .freeze2, .attack2, .attack3, .skill]
        } else if job.isMonster {
            // It seems that die action type is a little bit different.
            return [.idle, .walk, .attack, .hurt, /*.die*/]
        } else {
            return [.idle]
        }
    }
}

extension SpriteActionType {
    init?(forPlayerActionIndex actionIndex: Int) {
        let index = actionIndex / BodyDirection.allCases.count
        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: 0)
        guard index < availableActionTypes.count else {
            return nil
        }

        self = availableActionTypes[index]
    }

    public func calculateActionIndex(forJobID jobID: Int, direction: BodyDirection) -> Int {
        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: jobID)
        guard let index = availableActionTypes.firstIndex(of: self) else {
            return -1
        }

        let actionIndex = index * BodyDirection.allCases.count + direction.rawValue
        return actionIndex
    }
}

public enum BodyDirection: Int, CaseIterable, CustomStringConvertible, Sendable {
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

public enum HeadDirection: Int, CaseIterable, CustomStringConvertible, Sendable {
    case straight
    case left
    case right

    public var description: String {
        switch self {
        case .straight:
            "Straight"
        case .left:
            "Left"
        case .right:
            "Right"
        }
    }
}
