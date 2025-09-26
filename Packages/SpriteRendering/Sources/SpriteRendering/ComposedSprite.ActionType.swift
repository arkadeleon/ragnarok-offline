//
//  ComposedSprite.ActionType.swift
//  SpriteRendering
//
//  Created by Leon Li on 2025/5/6.
//

extension ComposedSprite {
    public enum ActionType: String, CaseIterable, CustomStringConvertible, Sendable {
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
}

extension ComposedSprite.ActionType {
    public static func availableActionTypes(forJobID jobID: Int) -> [ComposedSprite.ActionType] {
        let job = CharacterJob(rawValue: jobID)

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

extension ComposedSprite.ActionType {
    public func calculateActionIndex(forJobID jobID: Int, direction: ComposedSprite.Direction) -> Int {
        let availableActionTypes = ComposedSprite.ActionType.availableActionTypes(forJobID: jobID)
        guard let index = availableActionTypes.firstIndex(of: self) else {
            return -1
        }

        let actionIndex = index * ComposedSprite.Direction.allCases.count + direction.rawValue
        return actionIndex
    }
}
