//
//  SkillTreeDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaCommon
import rAthenaResource
import rAthenaRyml

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

    private(set) var cachedSkillTrees: [SkillTree] = []
    private(set) var cachedSkillTreesByJobIDs: [Int : SkillTree] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    func skillTrees() throws -> [SkillTree] {
        if cachedSkillTrees.isEmpty {
            let decoder = YAMLDecoder()

            let url = ResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("skill_tree.yml")
            let data = try Data(contentsOf: url)
            cachedSkillTrees = try decoder.decode(ListNode<SkillTree>.self, from: data).body
        }

        return cachedSkillTrees
    }

    public func skillTree(forJobID jobID: Int) throws -> SkillTree {
        if cachedSkillTreesByJobIDs.isEmpty {
            let skillTrees = try skillTrees()
            cachedSkillTreesByJobIDs = Dictionary(skillTrees.map({ ($0.job.id, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        if let skillTree = cachedSkillTreesByJobIDs[jobID] {
            return skillTree
        } else {
            throw DatabaseError.recordNotFound
        }
    }
}
