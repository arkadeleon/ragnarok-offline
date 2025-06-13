//
//  SkillTreeDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import RapidYAML
import rAthenaResources
import ROConstants

public actor SkillTreeDatabase {
    public static let prerenewal = SkillTreeDatabase(mode: .prerenewal)
    public static let renewal = SkillTreeDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> SkillTreeDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private lazy var _skillTrees: [SkillTree] = {
        metric.beginMeasuring("Load skill tree database")

        do {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/skill_tree.yml")
            let data = try Data(contentsOf: url)
            let skillTrees = try decoder.decode(ListNode<SkillTree>.self, from: data).body

            metric.endMeasuring("Load skill tree database")

            return skillTrees
        } catch {
            metric.endMeasuring("Load skill tree database", error)

            return []
        }
    }()

    private lazy var _skillTreesByJobID: [JobID : SkillTree] = {
        Dictionary(
            _skillTrees.map({ ($0.job, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    func skillTrees() -> [SkillTree] {
        _skillTrees
    }

    public func skillTree(for jobID: JobID) -> SkillTree? {
        _skillTreesByJobID[jobID]
    }
}
