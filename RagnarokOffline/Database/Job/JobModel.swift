//
//  JobModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import Constants
import CoreGraphics
import DatabaseCore
import Observation
import rAthenaCommon
import ResourceManagement
import SpriteRendering

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

    var localizedName: String?
    var animatedImage: AnimatedImage?

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
                DatabaseRecordAttribute(name: weaponType.localizedName, value: aspd)
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
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Job, Value>) -> Value {
        job[keyPath: keyPath]
    }

    @MainActor
    func fetchLocalizedName() async {
        let messageStringTable = await ResourceManager.shared.messageStringTable(for: .current)
        self.localizedName = messageStringTable.localizedJobName(for: job.id)
    }

    @MainActor
    func fetchAnimatedImage() async {
        if animatedImage != nil {
            return
        }

        let composedSprite: ComposedSprite
        do {
            let configuration = ComposedSprite.Configuration(jobID: job.id.rawValue)
            composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: .shared)
        } catch {
            logger.warning("Composed sprite error: \(error)")
            return
        }

        let spriteRenderer = SpriteRenderer()
        let animation = await spriteRenderer.render(
            composedSprite: composedSprite,
            actionType: .idle,
            direction: .south,
            headDirection: .straight
        )
        animatedImage = AnimatedImage(animation: animation)
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
