//
//  SkillSimulator.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/2/11.
//

import Foundation
import Observation
import RagnarokConstants

enum SkillAllocationError: LocalizedError {
    case notFound
    case noPoints(jobName: String)
    case maxLevelReached
    case belowZero
    case jobLevelNotMet(required: Int, jobName: String)
    case baseLevelNotMet(required: Int)
    case prerequisitesNotMet([SkillNode.Prerequisite])
    case requiredByDependentSkill([String])

    var errorDescription: String? {
        switch self {
        case .notFound:
            return String(
                localized: LocalizedStringResource(
                    "Skill is not available in this tree.",
                    table: "SkillSimulator"
                )
            )
        case .noPoints(let jobName):
            return String(
                localized: LocalizedStringResource(
                    "No remaining \(jobName) skill points.",
                    table: "SkillSimulator"
                )
            )
        case .maxLevelReached:
            return String(
                localized: LocalizedStringResource(
                    "Skill is already at maximum level.",
                    table: "SkillSimulator"
                )
            )
        case .belowZero:
            return String(
                localized: LocalizedStringResource(
                    "Skill is already at level 0.",
                    table: "SkillSimulator"
                )
            )
        case .jobLevelNotMet(let required, let jobName):
            return String(
                localized: LocalizedStringResource(
                    "Requires \(jobName) job level \(required).",
                    table: "SkillSimulator"
                )
            )
        case .baseLevelNotMet(let required):
            return String(
                localized: LocalizedStringResource(
                    "Requires base level \(required).",
                    table: "SkillSimulator"
                )
            )
        case .prerequisitesNotMet(let prerequisites):
            let descriptions = prerequisites.map { prerequisite in
                String(
                    localized: LocalizedStringResource(
                        "\(prerequisite.displayName) Lv \(prerequisite.level)",
                        table: "SkillSimulator"
                    )
                )
            }
            return String(
                localized: LocalizedStringResource(
                    "Missing prerequisites: \(descriptions.joined(separator: ", ")).",
                    table: "SkillSimulator"
                )
            )
        case .requiredByDependentSkill(let dependents):
            return String(
                localized: LocalizedStringResource(
                    "Cannot reduce this skill. Required by \(dependents.joined(separator: ", ")).",
                    table: "SkillSimulator"
                )
            )
        }
    }
}

enum SkillLockReason: CustomStringConvertible {
    case jobLevelNotMet(required: Int, jobName: String)
    case baseLevelNotMet(required: Int)
    case prerequisitesNotMet([SkillNode.Prerequisite])

    var description: String {
        switch self {
        case .jobLevelNotMet(let required, let jobName):
            return String(
                localized: LocalizedStringResource(
                    "Requires \(jobName) job level \(required).",
                    table: "SkillSimulator"
                )
            )
        case .baseLevelNotMet(let required):
            return String(
                localized: LocalizedStringResource(
                    "Requires base level \(required).",
                    table: "SkillSimulator"
                )
            )
        case .prerequisitesNotMet(let prerequisites):
            let descriptions = prerequisites.map { prerequisite in
                String(
                    localized: LocalizedStringResource(
                        "\(prerequisite.displayName) Lv \(prerequisite.level)",
                        table: "SkillSimulator"
                    )
                )
            }

            return String(
                localized: LocalizedStringResource(
                    "Requires \(descriptions.joined(separator: ", ")).",
                    table: "SkillSimulator"
                )
            )
        }
    }
}

@MainActor
@Observable
final class SkillSimulator {
    struct JobStage: Identifiable, Hashable {
        var jobID: JobID
        var displayName: String
        var maxBaseLevel: Int
        var maxJobLevel: Int
        var isSelectedJob: Bool

        var id: JobID {
            jobID
        }
    }

    var selectedJobID: JobID = .novice {
        didSet {
            persistSnapshot()
        }
    }

    var baseLevel: Int = 1 {
        didSet {
            persistSnapshot()
        }
    }

    var maxBaseLevel: Int {
        if let stage = jobStages.first(where: { $0.jobID == selectedJobID }) {
            return max(stage.maxBaseLevel, 1)
        }
        return 1
    }

    var jobLevelsByJobID: [JobID: Int] = [:] {
        didSet {
            persistSnapshot()
        }
    }

    var jobStages: [JobStage] = []
    var skillNodes: [SkillNode] = []
    var allocations: [String: Int] = [:] {
        didSet {
            persistSnapshot()
        }
    }

    var totalPoints: Int {
        jobStages.reduce(0) { partialResult, stage in
            partialResult + totalPoints(for: stage.jobID)
        }
    }

    var spentPoints: Int {
        allocations.values.reduce(0, +)
    }

    init() {
        restoreSnapshot()
    }

    func reset() {
        allocations = [:]
    }

    func bootstrap(jobs: [JobModel], skills: [SkillModel]) {
        guard !jobs.isEmpty else {
            jobStages = []
            skillNodes = []
            allocations = [:]
            return
        }

        if !jobs.contains(where: { $0.id == selectedJobID }) {
            selectedJobID = .novice
        }

        rebuildStagesAndTree(jobs: jobs, skills: skills)
    }

    func selectJob(_ jobID: JobID, jobs: [JobModel], skills: [SkillModel], resetAllocations: Bool) {
        selectedJobID = jobID
        if resetAllocations {
            allocations = [:]
        }

        rebuildStagesAndTree(jobs: jobs, skills: skills)
    }

    func updateBaseLevel(_ level: Int) {
        baseLevel = min(max(level, 1), maxBaseLevel)
    }

    func updateJobLevel(_ level: Int, for jobID: JobID) {
        guard let stage = jobStages.first(where: { $0.jobID == jobID }) else {
            return
        }

        let minimumLevel = minimumJobLevel(for: jobID)
        let clampedLevel = min(max(level, minimumLevel), stage.maxJobLevel)
        jobLevelsByJobID[jobID] = clampedLevel
    }

    func jobLevel(for jobID: JobID) -> Int {
        if let level = jobLevelsByJobID[jobID] {
            return level
        }

        if let stage = jobStages.first(where: { $0.jobID == jobID }) {
            return stage.isSelectedJob ? 1 : stage.maxJobLevel
        }

        return 1
    }

    func minimumJobLevel(for jobID: JobID) -> Int {
        guard let stage = jobStages.first(where: { $0.jobID == jobID }) else {
            return 1
        }

        let requiredLevelFromSpentPoints = spentPoints(for: jobID) + 1
        return min(max(requiredLevelFromSpentPoints, 1), stage.maxJobLevel)
    }

    func totalPoints(for jobID: JobID) -> Int {
        max(jobLevel(for: jobID) - 1, 0)
    }

    func spentPoints(for jobID: JobID) -> Int {
        skillNodes.reduce(0) { partialResult, skillNode in
            guard skillNode.source.jobID == jobID else {
                return partialResult
            }
            return partialResult + allocations[skillNode.aegisName, default: 0]
        }
    }

    func remainingPoints(for jobID: JobID) -> Int {
        totalPoints(for: jobID) - spentPoints(for: jobID)
    }

    func skillLevel(for aegisName: String) -> Int {
        allocations[aegisName, default: 0]
    }

    func incrementSkill(named aegisName: String) -> SkillAllocationError? {
        guard let skillNode = skillNodes.first(where: { $0.aegisName == aegisName }) else {
            return .notFound
        }

        let pointSourceJobID = skillNode.source.jobID
        let pointSourceJobName = skillNode.source.jobName
        if remainingPoints(for: pointSourceJobID) <= 0 {
            return .noPoints(jobName: pointSourceJobName)
        }

        let currentLevel = skillLevel(for: aegisName)
        if currentLevel >= skillNode.maxLevel {
            return .maxLevelReached
        }

        if jobLevel(for: pointSourceJobID) < skillNode.requiredJobLevel {
            return .jobLevelNotMet(required: skillNode.requiredJobLevel, jobName: pointSourceJobName)
        }

        if baseLevel < skillNode.requiredBaseLevel {
            return .baseLevelNotMet(required: skillNode.requiredBaseLevel)
        }

        let missingPrerequisites = unmetPrerequisites(for: skillNode)
        if !missingPrerequisites.isEmpty {
            return .prerequisitesNotMet(missingPrerequisites)
        }

        allocations[aegisName] = currentLevel + 1
        return nil
    }

    func decrementSkill(named aegisName: String) -> SkillAllocationError? {
        guard let skillNode = skillNodes.first(where: { $0.aegisName == aegisName }) else {
            return .notFound
        }

        let currentLevel = skillLevel(for: aegisName)
        if currentLevel <= 0 {
            return .belowZero
        }

        let nextLevel = currentLevel - 1
        let dependents = requiredDependentsIfDecremented(skillName: skillNode.aegisName, toLevel: nextLevel)
        if !dependents.isEmpty {
            return .requiredByDependentSkill(dependents)
        }

        if nextLevel == 0 {
            allocations.removeValue(forKey: aegisName)
        } else {
            allocations[aegisName] = nextLevel
        }

        return nil
    }

    func unmetPrerequisites(for skillNode: SkillNode) -> [SkillNode.Prerequisite] {
        skillNode.prerequisites.filter { prerequisite in
            skillLevel(for: prerequisite.aegisName) < prerequisite.level
        }
    }

    func isSkillUnlocked(_ skillNode: SkillNode) -> Bool {
        let pointSourceJobID = skillNode.source.jobID

        guard jobLevel(for: pointSourceJobID) >= skillNode.requiredJobLevel else {
            return false
        }

        guard baseLevel >= skillNode.requiredBaseLevel else {
            return false
        }

        return unmetPrerequisites(for: skillNode).isEmpty
    }

    func isIncrementEnabled(for skillNode: SkillNode) -> Bool {
        let pointSourceJobID = skillNode.source.jobID

        guard remainingPoints(for: pointSourceJobID) > 0 else {
            return false
        }
        guard skillLevel(for: skillNode.aegisName) < skillNode.maxLevel else {
            return false
        }
        return isSkillUnlocked(skillNode)
    }

    func isDecrementEnabled(for skillNode: SkillNode) -> Bool {
        skillLevel(for: skillNode.aegisName) > 0
    }

    func lockReason(for skillNode: SkillNode) -> SkillLockReason? {
        let pointSourceJobID = skillNode.source.jobID
        let pointSourceJobName = skillNode.source.jobName

        if jobLevel(for: pointSourceJobID) < skillNode.requiredJobLevel {
            return .jobLevelNotMet(required: skillNode.requiredJobLevel, jobName: pointSourceJobName)
        }

        if baseLevel < skillNode.requiredBaseLevel {
            return .baseLevelNotMet(required: skillNode.requiredBaseLevel)
        }

        let missingPrerequisites = unmetPrerequisites(for: skillNode)
        if !missingPrerequisites.isEmpty {
            return .prerequisitesNotMet(missingPrerequisites)
        }

        return nil
    }

    private func requiredDependentsIfDecremented(skillName: String, toLevel level: Int) -> [String] {
        skillNodes.compactMap { skillNode -> String? in
            let allocatedLevel = skillLevel(for: skillNode.aegisName)
            guard allocatedLevel > 0 else {
                return nil
            }

            guard let prerequisite = skillNode.prerequisites.first(where: { $0.aegisName == skillName }) else {
                return nil
            }

            if level < prerequisite.level {
                return skillNode.displayName
            } else {
                return nil
            }
        }
    }
}

// MARK: - Build

extension SkillSimulator {
    private func rebuildStagesAndTree(jobs: [JobModel], skills: [SkillModel]) {
        jobStages = buildJobStages(jobs: jobs)
        normalizeBaseLevel()
        normalizeJobLevels()

        let skillTreeResolver = SkillTreeResolver(jobs: jobs, skills: skills)
        skillNodes = skillTreeResolver.resolve(selectedJobID: selectedJobID)
        normalizeAllocations()
        normalizeJobLevelsForAllocations()
    }

    private func buildJobStages(jobs: [JobModel]) -> [JobStage] {
        let jobsByID = Dictionary(
            jobs.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        guard let selectedJob = jobsByID[selectedJobID] else {
            return []
        }

        let inheritedJobIDs = (selectedJob.skillTree?.inherit ?? []).filter { inheritedJobID in
            selectedJobID == .novice || inheritedJobID != .novice
        }
        let relevantJobIDs = Set(inheritedJobIDs).union([selectedJobID])
        if relevantJobIDs.isEmpty {
            return []
        }

        let inheritMap = Dictionary(
            jobs.map { ($0.id, $0.skillTree?.inherit ?? []) },
            uniquingKeysWith: { first, _ in first }
        )

        var depthByJobID: [JobID: Int] = [:]
        var visiting: Set<JobID> = []

        func depth(of jobID: JobID) -> Int {
            if let depth = depthByJobID[jobID] {
                return depth
            }

            if visiting.contains(jobID) {
                return 0
            }

            visiting.insert(jobID)

            let parentJobIDs = (inheritMap[jobID] ?? []).filter { relevantJobIDs.contains($0) }
            let jobDepth: Int
            if parentJobIDs.isEmpty {
                jobDepth = 0
            } else {
                let parentDepth = parentJobIDs.map { depth(of: $0) }.max() ?? 0
                jobDepth = parentDepth + 1
            }

            visiting.remove(jobID)
            depthByJobID[jobID] = jobDepth
            return jobDepth
        }

        let orderedJobIDs = relevantJobIDs.sorted { lhs, rhs in
            let lhsDepth = depth(of: lhs)
            let rhsDepth = depth(of: rhs)
            if lhsDepth == rhsDepth {
                return lhs.rawValue < rhs.rawValue
            }
            return lhsDepth < rhsDepth
        }

        return orderedJobIDs.compactMap { jobID in
            guard let job = jobsByID[jobID] else {
                return nil
            }

            return JobStage(
                jobID: jobID,
                displayName: job.displayName,
                maxBaseLevel: max(job.maxBaseLevel ?? 1, 1),
                maxJobLevel: max(job.maxJobLevel ?? 1, 1),
                isSelectedJob: jobID == selectedJobID
            )
        }
    }

    private func normalizeBaseLevel() {
        baseLevel = maxBaseLevel
    }

    private func normalizeJobLevels() {
        let validJobIDs = Set(jobStages.map(\.jobID))
        var normalizedJobLevels = jobLevelsByJobID.filter { validJobIDs.contains($0.key) }

        for stage in jobStages {
            let defaultLevel = stage.maxJobLevel
            let existingLevel = normalizedJobLevels[stage.jobID] ?? defaultLevel
            let clampedLevel = min(max(existingLevel, 1), stage.maxJobLevel)
            normalizedJobLevels[stage.jobID] = clampedLevel
        }

        jobLevelsByJobID = normalizedJobLevels
    }

    private func normalizeJobLevelsForAllocations() {
        var normalizedJobLevels = jobLevelsByJobID

        for stage in jobStages {
            let existingLevel = normalizedJobLevels[stage.jobID] ?? stage.maxJobLevel
            let minimumLevel = minimumJobLevel(for: stage.jobID)
            let clampedLevel = min(max(existingLevel, minimumLevel), stage.maxJobLevel)
            normalizedJobLevels[stage.jobID] = clampedLevel
        }

        jobLevelsByJobID = normalizedJobLevels
    }

    private func normalizeAllocations() {
        let nodeNames = Set(skillNodes.map(\.aegisName))
        allocations = allocations.filter { nodeNames.contains($0.key) && $0.value > 0 }

        for skillNode in skillNodes {
            let allocatedLevel = skillLevel(for: skillNode.aegisName)
            if allocatedLevel > skillNode.maxLevel {
                allocations[skillNode.aegisName] = skillNode.maxLevel
            }
        }
    }
}

// MARK: - Snapshot

extension SkillSimulator {
    private struct Snapshot: Codable {
        var selectedJobIDRawValue: Int
        var baseLevel: Int
        var jobLevelsByJobIDRawValue: [Int: Int]
        var allocations: [String: Int]
    }

    private static let snapshotKey = "skillSimulatorSnapshot"

    private func restoreSnapshot() {
        guard let data = UserDefaults.standard.data(forKey: SkillSimulator.snapshotKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return
        }

        if let restoredJobID = JobID(rawValue: snapshot.selectedJobIDRawValue) {
            selectedJobID = restoredJobID
        }
        baseLevel = max(snapshot.baseLevel, 1)

        var restoredJobLevels: [JobID: Int] = [:]
        for (jobIDRawValue, level) in snapshot.jobLevelsByJobIDRawValue {
            if let jobID = JobID(rawValue: jobIDRawValue), level > 0 {
                restoredJobLevels[jobID] = level
            }
        }
        jobLevelsByJobID = restoredJobLevels

        allocations = snapshot.allocations.filter { $0.value > 0 }
    }

    private func persistSnapshot() {
        let snapshot = Snapshot(
            selectedJobIDRawValue: selectedJobID.rawValue,
            baseLevel: max(baseLevel, 1),
            jobLevelsByJobIDRawValue: Dictionary(
                uniqueKeysWithValues: jobLevelsByJobID.map { ($0.key.rawValue, max($0.value, 1)) }
            ),
            allocations: allocations.filter { $0.value > 0 }
        )

        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        UserDefaults.standard.set(data, forKey: SkillSimulator.snapshotKey)
    }
}
