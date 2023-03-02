//
//  Monster.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/3/2.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaCommon

extension RAMonster {
    typealias Attribute = (name: String, value: String)

    var attributes: [Attribute] {
        let attributes: [Attribute?] = [
            ("Level", String(level)),
            ("HP", String(hp)),
            (sp > 1 ? ("SP", String(sp)) : nil),
            ("Base Experience", String(baseExp)),
            ("Job Experience", String(jobExp)),
            (mvpExp > 0 ? ("MVP Experience", String(mvpExp)) : nil),
            ("Attack", String(attack)),
            ("Attack2", String(attack2)),
            ("Defense", String(defense)),
            ("Magic Defense", String(magicDefense)),
            (resistance > 0 ? ("Resistance", String(resistance)) : nil),
            (magicResistance > 0 ? ("Magic Resistance", String(magicResistance)) : nil),
            ("Str", String(strength)),
            ("Agi", String(agility)),
            ("Vit", String(vitality)),
            ("Int", String(intelligence)),
            ("Dex", String(dexterity)),
            ("Luk", String(luck)),
            ("Attack Range", String(attackRange)),
            ("Skill Cast Range", String(skillRange)),
            ("Chase Range", String(chaseRange)),
            ("Size", size.name),
            ("Race", race.name),
            ("Element", "\(element.name) \(elementLevel)"),
            ("Walk Speed", String(walkSpeed)),
            ("Attack Speed", String(attackDelay)),
            ("Attack Animation Speed", String(attackMotion)),
            ("Damage Animation Speed", String(damageMotion)),
        ]
        return attributes.compactMap({ $0 })
    }
}

extension RAMonsterSize {
    var name: String {
        switch self {
        case .small:
            return "Small"
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        @unknown default:
            fatalError()
        }
    }
}

extension RAMonsterRace {
    var name: String {
        switch self {
        case .formless:
            return "Formless"
        case .undead:
            return "Undead"
        case .brute:
            return "Brute"
        case .plant:
            return "Plant"
        case .insect:
            return "Insect"
        case .fish:
            return "Fish"
        case .demon:
            return "Demon"
        case .demihuman:
            return "Demihuman"
        case .angel:
            return "Angel"
        case .dragon:
            return "Dragon"
        @unknown default:
            fatalError()
        }
    }
}

extension RAMonsterElement {
    var name: String {
        switch self {
        case .neutral:
            return "Neutral"
        case .water:
            return "Water"
        case .earth:
            return "Earth"
        case .fire:
            return "Fire"
        case .wind:
            return "Wind"
        case .poison:
            return "Poison"
        case .holy:
            return "Holy"
        case .dark:
            return "Dark"
        case .ghost:
            return "Ghost"
        case .undead:
            return "Undead"
        @unknown default:
            fatalError()
        }
    }
}
