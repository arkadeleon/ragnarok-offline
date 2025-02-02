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

    private lazy var _skills: [Skill] = (try? {
        let decoder = YAMLDecoder()

        let url = ServerResourceManager.default.sourceURL
            .appending(path: "db/\(mode.path)/skill_db.yml")
        let data = try Data(contentsOf: url)
        let skills = try decoder.decode(ListNode<Skill>.self, from: data).body

        return skills
    }()) ?? []

    private lazy var _skillsByID: [Int : Skill] = {
        Dictionary(
            _skills.map({ ($0.id, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    private lazy var _skillsByAegisName: [String : Skill] = {
        Dictionary(
            _skills.map({ ($0.aegisName, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func skills() -> [Skill] {
        _skills
    }

    public func skill(forID id: Int) -> Skill? {
        _skillsByID[id]
    }

    public func skill(forAegisName aegisName: String) -> Skill? {
        _skillsByAegisName[aegisName]
    }
}
