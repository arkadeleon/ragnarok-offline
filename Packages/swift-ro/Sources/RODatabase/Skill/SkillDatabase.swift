//
//  SkillDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaResources

public actor SkillDatabase {
    public static let prerenewal = SkillDatabase(mode: .prerenewal)
    public static let renewal = SkillDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> SkillDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private var cachedSkills: [Skill] = []
    private var cachedSkillsByID: [Int : Skill] = [:]
    private var cachedSkillsByAegisName: [String : Skill] = [:]

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func skills() throws -> [Skill] {
        if cachedSkills.isEmpty {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.path)
                .appendingPathComponent("skill_db.yml")
            let data = try Data(contentsOf: url)
            cachedSkills = try decoder.decode(ListNode<Skill>.self, from: data).body
        }

        return cachedSkills
    }

    public func skill(forID id: Int) throws -> Skill? {
        if cachedSkillsByID.isEmpty {
            let skills = try skills()
            cachedSkillsByID = Dictionary(skills.map({ ($0.id, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let skillTree = cachedSkillsByID[id]
        return skillTree
    }

    public func skill(forAegisName aegisName: String) throws -> Skill? {
        if cachedSkillsByAegisName.isEmpty {
            let skills = try skills()
            cachedSkillsByAegisName = Dictionary(skills.map({ ($0.aegisName, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let skill = cachedSkillsByAegisName[aegisName]
        return skill
    }
}
