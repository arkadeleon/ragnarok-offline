//
//  SkillTreeDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import ROGenerated
import rAthenaResources

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

    private var cachedSkillTrees: [SkillTree] = []
    private var cachedSkillTreesByJobID: [JobID : SkillTree] = [:]

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    func skillTrees() throws -> [SkillTree] {
        if cachedSkillTrees.isEmpty {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.path)
                .appendingPathComponent("skill_tree.yml")
            let data = try Data(contentsOf: url)
            cachedSkillTrees = try decoder.decode(ListNode<SkillTree>.self, from: data).body
        }

        return cachedSkillTrees
    }

    public func skillTree(forJobID jobID: JobID) throws -> SkillTree? {
        if cachedSkillTreesByJobID.isEmpty {
            let skillTrees = try skillTrees()
            cachedSkillTreesByJobID = Dictionary(skillTrees.map({ ($0.job, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let skillTree = cachedSkillTreesByJobID[jobID]
        return skillTree
    }
}
