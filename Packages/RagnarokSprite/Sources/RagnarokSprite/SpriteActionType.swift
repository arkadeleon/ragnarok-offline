//
//  SpriteActionType.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2025/5/6.
//

public enum SpriteActionType: String, CaseIterable, CustomStringConvertible, Sendable {
    case idle
    case walk
    case sit
    case pickup
    case readyToAttack
    case attack1
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
        case .readyToAttack:
            "Ready to Attack"
        case .attack1:
            "Attack 1"
        case .hurt:
            "Hurt"
        case .freeze:
            "Freeze"
        case .die:
            "Die"
        case .freeze2:
            "Freeze"
        case .attack2:
            "Attack 2"
        case .attack3:
            "Attack 3"
        case .skill:
            "Skill"
        }
    }
}

extension SpriteActionType {
    public static func availableActionTypes(forJobID jobID: Int) -> [SpriteActionType] {
        let job = SpriteJob(rawValue: jobID)

        if job.isPlayer {
            return [.idle, .walk, .sit, .pickup, .readyToAttack, .attack1, .hurt, .freeze, .die, .freeze2, .attack2, .attack3, .skill]
        } else if job.isMonster {
            // It seems that die action type is a little bit different.
            return [.idle, .walk, .attack1, .hurt, /*.die*/]
        } else {
            return [.idle]
        }
    }
}

extension SpriteActionType {
    public func calculateActionIndex(forJobID jobID: Int, direction: SpriteDirection) -> Int {
        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: jobID)
        guard let index = availableActionTypes.firstIndex(of: self) else {
            return -1
        }

        let actionIndex = index * SpriteDirection.allCases.count + direction.rawValue
        return actionIndex
    }
}
