//
//  ObservableJob.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import ROCore
import RODatabase
import ROGenerated
import RORendering

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

    var animatedImage: AnimatedImage?
    var skills: [ObservableSkill] = []

    var displayName: String {
        job.id.stringValue
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

    @MainActor
    func fetchAnimatedImage() async {
        if animatedImage == nil {
            let jobID = UniformJobID(rawValue: job.id.rawValue)
            let spriteResolver = SpriteResolver(resourceManager: .default)
            let sprites = await spriteResolver.resolve(jobID: jobID, configuration: SpriteConfiguration())

            let spriteRenderer = SpriteRenderer(sprites: sprites)
            animatedImage = await spriteRenderer.renderAction(at: 0, headDirection: .straight)
        }
    }

    @MainActor
    func fetchDetail() async {
        let skillDatabase = SkillDatabase.database(for: mode)
        let skillTreeDatabase = SkillTreeDatabase.database(for: mode)

        if let skillTree = await skillTreeDatabase.skillTree(forJobID: job.id)?.tree {
            var skills: [ObservableSkill] = []
            for s in skillTree {
                if let skill = await skillDatabase.skill(forAegisName: s.name) {
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
