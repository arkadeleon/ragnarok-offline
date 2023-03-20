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
            ("Attack 2", String(attack2)),
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
            ("Size", size.englishName),
            ("Race", race.englishName),
            ("Element", "\(element.englishName) \(elementLevel)"),
            ("Walk Speed", String(walkSpeed)),
            ("Attack Speed", String(attackDelay)),
            ("Attack Animation Speed", String(attackMotion)),
            ("Damage Animation Speed", String(damageMotion)),
        ]
        return attributes.compactMap({ $0 })
    }
}
