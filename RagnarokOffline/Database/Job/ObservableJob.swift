//
//  ObservableJob.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import ROClientResources
import RODatabase
import ROGenerated

@Observable
@dynamicMemberLookup
class ObservableJob {
    struct BaseLevelStats: Identifiable {
        var level: Int
        var baseExp: Int
        var baseHp: Int
        var baseSp: Int

        var id: Int {
            level
        }
    }

    struct JobLevelStats: Identifiable {
        var level: Int
        var jobExp: Int
        var bonusStats: String

        var id: Int {
            level
        }
    }

    private let mode: DatabaseMode
    private let job: Job

    var image: CGImage?
    var skills: [ObservableSkill] = []

    var displayName: String {
        job.id.stringValue
    }

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: "Max Weight", value: job.maxWeight))
        attributes.append(.init(name: "HP Factor", value: job.hpFactor))
        attributes.append(.init(name: "HP Increase", value: job.hpIncrease))
        attributes.append(.init(name: "SP Increase", value: job.spIncrease))

        return attributes
    }

    var baseASPD: [DatabaseRecordAttribute] {
        WeaponType.allCases.compactMap { weaponType in
            if let aspd = job.baseASPD[weaponType] {
                DatabaseRecordAttribute(name: weaponType.localizedStringResource, value: aspd)
            } else {
                nil
            }
        }
    }

    var baseLevels: [BaseLevelStats] {
        (0..<job.maxBaseLevel).map { level in
            BaseLevelStats(
                level: level,
                baseExp: job.baseExp[level],
                baseHp: job.baseHp[level],
                baseSp: job.baseSp[level]
            )
        }
    }

    var jobLevels: [JobLevelStats] {
        (0..<job.maxJobLevel).map { level in
            let bonusStats = Parameter.allCases.compactMap { parameter in
                if let value = job.bonusStats[level][parameter], value > 0 {
                    return "\(parameter.stringValue)(+\(value))"
                } else {
                    return nil
                }
            }.joined(separator: " ")

            return JobLevelStats(
                level: level,
                jobExp: job.jobExp[level],
                bonusStats: bonusStats
            )
        }
    }

    init(mode: DatabaseMode, job: Job) {
        self.mode = mode
        self.job = job
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Job, Value>) -> Value {
        job[keyPath: keyPath]
    }

    func fetchImage() async {
        if image == nil {
            image = await ClientResourceManager.default.jobImage(sex: .male, jobID: job.id)
        }
    }

    func fetchDetail() async {
        await fetchImage()

        let skillDatabase = SkillDatabase.database(for: mode)
        let skillTreeDatabase = SkillTreeDatabase.database(for: mode)

        if let skillTree = try? await skillTreeDatabase.skillTree(forJobID: job.id)?.tree {
            var skills: [ObservableSkill] = []
            for s in skillTree {
                if let skill = try? await skillDatabase.skill(forAegisName: s.name) {
                    skills.append(ObservableSkill(mode: mode, skill: skill))
                }
            }
            self.skills = skills
        }
    }
}

extension ObservableJob: Hashable {
    static func == (lhs: ObservableJob, rhs: ObservableJob) -> Bool {
        lhs.job.id == rhs.job.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(job.id)
    }
}

extension ObservableJob: Identifiable {
    var id: JobID {
        job.id
    }
}