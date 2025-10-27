//
//  CharacterActionType.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2025/5/6.
//

import RagnarokConstants

public enum CharacterActionType: String, CaseIterable, CustomStringConvertible, Sendable {
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

extension CharacterActionType {
    public static func availableActionTypes(forJobID jobID: Int) -> [CharacterActionType] {
        let job = CharacterJob(rawValue: jobID)

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

extension CharacterActionType {
    public func calculateActionIndex(forJobID jobID: Int, direction: CharacterDirection) -> Int {
        let availableActionTypes = CharacterActionType.availableActionTypes(forJobID: jobID)
        guard let index = availableActionTypes.firstIndex(of: self) else {
            return -1
        }

        let actionIndex = index * CharacterDirection.allCases.count + direction.rawValue
        return actionIndex
    }
}

extension CharacterActionType {
    static func attackActionType(for baseJobID: JobID, gender: Gender, weaponType: WeaponType) -> CharacterActionType {
        switch (baseJobID, gender) {
        case (.novice, .female):
            switch weaponType {
            case .w_fist: .attack1
            case .w_dagger: .attack3
            default: .attack2
            }
        case (.novice, .male):
            switch weaponType {
            case .w_fist: .attack1
            case .w_dagger: .attack2
            default: .attack3
            }
        default:
            .attack1
        }
    }

    public static func attackActionType(forJobID jobID: Int, gender: Gender, weapon: Int) -> CharacterActionType {
        guard let jobID = JobID(rawValue: jobID), let weaponType = WeaponType(rawValue: weapon) else {
            return .attack1
        }

        let baseJobID: JobID = switch jobID {
        case .novice, .novice_high, .baby: .novice
        default: .novice
        }

        let attackActionType = attackActionType(for: baseJobID, gender: gender, weaponType: weaponType)
        return attackActionType
    }
}
