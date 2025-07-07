//
//  JobModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import rAthenaCommon
import ROConstants
import ROCore
import RODatabase
import RORendering
import ROResources

@Observable
@dynamicMemberLookup
final class JobModel {
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

    private let localizedName: String?

    var animatedImage: AnimatedImage?
    var skills: [SkillModel] = []

    var displayName: String {
        localizedName ?? job.id.stringValue
    }

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: "Max Weight", value: job.maxWeight))
        attributes.append(.init(name: "HP Factor", value: job.hpFactor))
        attributes.append(.init(name: "HP Increase", value: job.hpIncrease))
        attributes.append(.init(name: "SP Factor", value: job.spFactor))
        attributes.append(.init(name: "SP Increase", value: job.spIncrease))
        attributes.append(.init(name: "AP Factor", value: job.apFactor))
        attributes.append(.init(name: "AP Increase", value: job.apIncrease))

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
        let maxBaseLevel = job.maxBaseLevel ?? RA_MAX_LEVEL
        let baseLevels = (1...maxBaseLevel).map { level in
            BaseLevelStats(
                level: level,
                baseExp: job.baseExp[level] ?? 0,
                baseHp: job.baseHp[level] ?? 0,
                baseSp: job.baseSp[level] ?? 0
            )
        }
        return baseLevels
    }

    var jobLevels: [JobLevelStats] {
        let maxJobLevel = job.maxJobLevel ?? RA_MAX_LEVEL
        let jobLevels = (1...maxJobLevel).map { level in
            let bonusStats = Parameter.allCases.compactMap { parameter in
                if let value = job.bonusStats[level]?[parameter], value > 0 {
                    return "\(parameter.stringValue)(+\(value))"
                } else {
                    return nil
                }
            }.joined(separator: " ")

            return JobLevelStats(
                level: level,
                jobExp: job.jobExp[level] ?? 0,
                bonusStats: bonusStats
            )
        }
        return jobLevels
    }

    init(mode: DatabaseMode, job: Job) {
        self.mode = mode
        self.job = job

        self.localizedName = MessageStringTable.current.localizedJobName(for: job.id)
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Job, Value>) -> Value {
        job[keyPath: keyPath]
    }

    @MainActor
    func fetchAnimatedImage() async {
        if animatedImage == nil {
            let configuration = ComposedSprite.Configuration(jobID: job.id.rawValue)
            let composedSprite = await ComposedSprite(configuration: configuration, resourceManager: .shared)

            let spriteRenderer = SpriteRenderer()
            animatedImage = await spriteRenderer.render(
                composedSprite: composedSprite,
                actionType: .idle,
                direction: .south,
                headDirection: .straight
            )
        }
    }

    @MainActor
    func fetchDetail() async {
        let skillDatabase = SkillDatabase.shared
        let skillTreeDatabase = SkillTreeDatabase.shared

        if let skillTree = await skillTreeDatabase.skillTree(for: job.id)?.tree {
            var skills: [SkillModel] = []
            for s in skillTree {
                if let skill = await skillDatabase.skill(forAegisName: s.name) {
                    let skill = await SkillModel(mode: mode, skill: skill)
                    skills.append(skill)
                }
            }
            self.skills = skills
        }
    }
}

extension JobModel: Equatable {
    static func == (lhs: JobModel, rhs: JobModel) -> Bool {
        lhs.job.id == rhs.job.id
    }
}

extension JobModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(job.id)
    }
}

extension JobModel: Identifiable {
    var id: JobID {
        job.id
    }
}
