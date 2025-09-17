//
//  SkillDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import RapidYAML

public actor SkillDatabase {
    public let sourceURL: URL
    public let mode: DatabaseMode

    private lazy var _skills: [Skill] = {
        metric.beginMeasuring("Load skill database")

        do {
            let decoder = YAMLDecoder()

            let url = sourceURL.appending(path: "db/\(mode.path)/skill_db.yml")
            let data = try Data(contentsOf: url)
            let skills = try decoder.decode(ListNode<Skill>.self, from: data).body

            metric.endMeasuring("Load skill database")

            return skills
        } catch {
            metric.endMeasuring("Load skill database", error)

            return []
        }
    }()

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

    public init(sourceURL: URL, mode: DatabaseMode) {
        self.sourceURL = sourceURL
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
