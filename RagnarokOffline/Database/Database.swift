//
//  Database.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/1/12.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import Foundation
import rAthenaCommon

@MainActor
class Database: ObservableObject {
    @Published var items: [RAItem] = []
    @Published var monsters: [RAMonster] = []
    @Published var skillTrees: [RASkillTree] = []
    @Published var skills: [RASkill] = []

    private var itemsWithNames: [String: RAItem] = [:]
    private var monstersWithNames: [String: RAMonster] = [:]
    private var skillTreesWithJobNames: [String: RASkillTree] = [:]
    private var skillsWithNames: [String: RASkill] = [:]

    func fetchItems() async {
        if !items.isEmpty {
            return
        }

        items = await RADatabase.renewal.fetchItems()
        itemsWithNames = Dictionary(uniqueKeysWithValues: items.map({ ($0.aegisName, $0) }))
    }

    func fetchMonsters() async {
        if !monsters.isEmpty {
            return
        }

        monsters = await RADatabase.renewal.fetchMonsters()
        monstersWithNames = Dictionary(uniqueKeysWithValues: monsters.map({ ($0.aegisName, $0) }))
    }

    func fetchSkillTrees() async {
        if !skillTrees.isEmpty {
            return
        }

        skillTrees = await RADatabase.renewal.fetchSkillTrees()
        skillTreesWithJobNames = Dictionary(uniqueKeysWithValues: skillTrees.map({ ($0.job.name, $0) }))

        skills = await RADatabase.renewal.fetchSkills()
        skillsWithNames = Dictionary(uniqueKeysWithValues: skills.map({ ($0.skillName, $0) }))
    }

    func item(for aegisName: String) -> RAItem? {
        itemsWithNames[aegisName]
    }

    func skillTree(for jobName: String) -> RASkillTree? {
        skillTreesWithJobNames[jobName]
    }

    func skill(for name: String) -> RASkill? {
        skillsWithNames[name]
    }
}

extension RAJob: Comparable {
    public static func < (lhs: RAJob, rhs: RAJob) -> Bool {
        lhs.value < rhs.value
    }
}
