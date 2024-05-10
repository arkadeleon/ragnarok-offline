//
//  SkillDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaCommon
import rAthenaResource
import rAthenaRyml

public actor SkillDatabase {
    public static let prerenewal = SkillDatabase(mode: .prerenewal)
    public static let renewal = SkillDatabase(mode: .renewal)

    public static func database(for mode: ServerMode) -> SkillDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private var cachedSkills: [Skill] = []
    private var cachedSkillsByIDs: [Int : Skill] = [:]
    private var cachedSkillsByAegisNames: [String : Skill] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func skills() throws -> [Skill] {
        if cachedSkills.isEmpty {
            let decoder = YAMLDecoder()

            let url = ResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("skill_db.yml")
            let data = try Data(contentsOf: url)
            cachedSkills = try decoder.decode(ListNode<Skill>.self, from: data).body
        }

        return cachedSkills
    }

    public func skill(forID id: Int) throws -> Skill {
        if cachedSkillsByIDs.isEmpty {
            let skills = try skills()
            cachedSkillsByIDs = Dictionary(skills.map({ ($0.id, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        if let skillTree = cachedSkillsByIDs[id] {
            return skillTree
        } else {
            throw DatabaseError.recordNotFound
        }
    }

    public func skill(forAegisName aegisName: String) throws -> Skill {
        if cachedSkillsByAegisNames.isEmpty {
            let skills = try skills()
            cachedSkillsByAegisNames = Dictionary(skills.map({ ($0.aegisName, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        if let skill = cachedSkillsByAegisNames[aegisName] {
            return skill
        } else {
            throw DatabaseError.recordNotFound
        }
    }
}
