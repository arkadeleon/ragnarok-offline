//
//  SkillTreeDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaCommon
import rAthenaResources

public actor SkillTreeDatabase {
    public static let prerenewal = SkillTreeDatabase(mode: .prerenewal)
    public static let renewal = SkillTreeDatabase(mode: .renewal)

    public static func database(for mode: ServerMode) -> SkillTreeDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private var cachedSkillTrees: [SkillTree] = []
    private var cachedSkillTreesByJobs: [Job : SkillTree] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    func skillTrees() throws -> [SkillTree] {
        if cachedSkillTrees.isEmpty {
            let decoder = YAMLDecoder()

            let url = ServerResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("skill_tree.yml")
            let data = try Data(contentsOf: url)
            cachedSkillTrees = try decoder.decode(ListNode<SkillTree>.self, from: data).body
        }

        return cachedSkillTrees
    }

    public func skillTree(forJob job: Job) throws -> SkillTree? {
        if cachedSkillTreesByJobs.isEmpty {
            let skillTrees = try skillTrees()
            cachedSkillTreesByJobs = Dictionary(skillTrees.map({ ($0.job, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let skillTree = cachedSkillTreesByJobs[job]
        return skillTree
    }
}
