//
//  SkillTreeResolver.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/2/11.
//

import RagnarokConstants
import RagnarokDatabase

struct SkillTreeResolver {
    private let jobsByID: [JobID: JobModel]
    private let treesByJobID: [JobID: SkillTree]
    private let skillsByAegisName: [String: SkillModel]

    init(jobs: [JobModel], skills: [SkillModel]) {
        self.jobsByID = Dictionary(
            jobs.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        self.treesByJobID = Dictionary(
            jobs.compactMap { job in
                guard let skillTree = job.skillTree else {
                    return nil
                }
                return (job.id, skillTree)
            },
            uniquingKeysWith: { first, _ in first }
        )

        self.skillsByAegisName = Dictionary(
            skills.map({ ($0.aegisName, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }

    func resolve(selectedJobID: JobID) -> [SkillNode] {
        guard let selectedJob = jobsByID[selectedJobID],
              let selectedSkillTree = selectedJob.skillTree else {
            return []
        }

        var mergedNodes: [SkillNode] = []

        // rAthena inheritance only copies the direct Tree of inherited jobs.
        let inheritedJobIDs = (selectedSkillTree.inherit ?? [])
            .filter { inheritedJobID in
                selectedJobID == .novice || inheritedJobID != .novice
            }
            .sorted(by: { $0.rawValue < $1.rawValue })
        for inheritedJobID in inheritedJobIDs {
            guard let inheritedJob = jobsByID[inheritedJobID],
                  let inheritedSkillTree = treesByJobID[inheritedJobID] else {
                continue
            }

            merge(
                skills: inheritedSkillTree.tree ?? [],
                source: .inherited(jobID: inheritedJobID, jobName: inheritedJob.displayName),
                into: &mergedNodes
            )
        }

        merge(
            skills: selectedSkillTree.tree ?? [],
            source: .direct(jobID: selectedJobID, jobName: selectedJob.displayName),
            into: &mergedNodes
        )

        return mergedNodes
    }

    private func merge(
        skills: [SkillTree.Skill],
        source: SkillNode.Source,
        into nodes: inout [SkillNode]
    ) {
        for skill in skills {
            if case .inherited = source, skill.exclude {
                continue
            }

            let aegisName = skill.name
            if skill.maxLevel <= 0 {
                if let index = nodes.firstIndex(where: { $0.aegisName == aegisName }) {
                    nodes.remove(at: index)
                }
                continue
            }

            let skillModel = skillsByAegisName[aegisName]
            let displayName = skillModel?.displayName ?? aegisName
            let prerequisites = (skill.requires ?? []).map { requiredSkill in
                let requiredDisplayName = skillsByAegisName[requiredSkill.name]?.displayName ?? requiredSkill.name
                return SkillNode.Prerequisite(
                    aegisName: requiredSkill.name,
                    displayName: requiredDisplayName,
                    level: requiredSkill.level
                )
            }

            let node = SkillNode(
                aegisName: aegisName,
                displayName: displayName,
                maxLevel: skill.maxLevel,
                requiredBaseLevel: skill.baseLevel,
                requiredJobLevel: skill.jobLevel,
                prerequisites: prerequisites,
                source: source
            )

            if let index = nodes.firstIndex(where: { $0.aegisName == aegisName }) {
                nodes[index] = node
            } else {
                nodes.append(node)
            }
        }
    }
}
