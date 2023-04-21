//
//  Skill.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/3/30.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaCommon

extension RASkillTree: Identifiable {
    public var id: String {
        job.name
    }
}

extension RASkill: Identifiable {
    public var id: Int {
        skillID
    }
}

extension RASkill {
    typealias Attribute = (name: String, value: String)

    var attributes: [Attribute] {
        let attributes: [Attribute?] = [
            ("Max Level", String(maxLevel)),
            ("Type", type.englishName),
            ("Target Type", targetType.englishName),
        ]
        return attributes.compactMap({ $0 })
    }
}
