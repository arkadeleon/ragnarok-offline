//
//  JobStats.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/11.
//

public struct JobStats: Equatable, Hashable {

    /// Job.
    public var job: Job

    /// Base maximum weight. (Default: 20000)
    public var maxWeight: Int

    /// Exponential HP increase. Per base level: [HpFactor * BaseLv / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 0)
    public var hpFactor: Int

    /// Linear HP increase. Per base level: [HpIncrease / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 500)
    public var hpIncrease: Int

    /// Linear SP increase. Per base level: [SpIncrease / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 100)
    public var spIncrease: Int

    /// Job level bonus stats/traits.
    public var bonusStats: [[Parameter : Int]]

    /// Base ASPD for each weapon type. (Default: 2000)
    public var baseASPD: [WeaponType : Int]

    /// Maximum base level. (Default: MAX_LEVEL)
    public var maxBaseLevel: Int

    /// Base experience per level.
    public var baseExp: [Int]

    /// Maximum job level. (Default: MAX_LEVEL)
    public var maxJobLevel: Int

    /// Job experience per level.
    public var jobExp: [Int]

    /// Base HP per base level.
    public var baseHp: [Int]

    /// Base SP per base level.
    public var baseSp: [Int]

    /// Base AP per base level.
    public var baseAp: [Int]

    init?(job: Job, basicStatsList: [JobBasicStats], aspdStatsList: [JobASPDStats], expStatsList: [JobExpStats], basePointsStatsList: [JobBasePointsStats]) {
        guard let basicStats = basicStatsList.first(where: { $0.jobs.contains(job) }),
              let aspdStats = aspdStatsList.first(where: { $0.jobs.contains(job) }),
              let baseExpStats = expStatsList.first(where: { $0.jobs.contains(job) && !$0.baseExp.isEmpty }),
              let jobExpStats = expStatsList.first(where: { $0.jobs.contains(job) && !$0.jobExp.isEmpty }),
              let baseHpPointsStats = basePointsStatsList.first(where: { $0.jobs.contains(job) && !$0.baseHp.isEmpty }),
              let baseSpPointsStats = basePointsStatsList.first(where: { $0.jobs.contains(job) && !$0.baseSp.isEmpty })
        else {
            print("Failed to init JobStats for \(job.stringValue)")
            return nil
        }

        self.job = job

        self.maxWeight = basicStats.maxWeight
        self.hpFactor = basicStats.hpFactor
        self.hpIncrease = basicStats.hpIncrease
        self.spIncrease = basicStats.spIncrease

        self.baseASPD = aspdStats.baseASPD

        self.maxBaseLevel = baseExpStats.maxBaseLevel
        self.baseExp = (1...maxBaseLevel).map { level in
            baseExpStats.baseExp.first(where: { $0.level == level })?.exp ?? 0
        }

        self.maxJobLevel = jobExpStats.maxJobLevel
        self.jobExp = (1...maxJobLevel).map { level in
            jobExpStats.jobExp.first(where: { $0.level == level })?.exp ?? 0
        }

        self.baseHp = (1...maxBaseLevel).map { level in
            baseHpPointsStats.baseHp.first(where: { $0.level == level })?.hp ?? 0
        }

        self.baseSp = (1...maxBaseLevel).map { level in
            baseSpPointsStats.baseSp.first(where: { $0.level == level })?.sp ?? 0
        }

        self.baseAp = Array(repeating: 0, count: maxBaseLevel)

        self.bonusStats = (1...maxJobLevel).map { level in
            let levelBonusStats = basicStats.bonusStats.first(where: { $0.level == level })
            return [
                .str: levelBonusStats?.str ?? 0,
                .agi: levelBonusStats?.agi ?? 0,
                .vit: levelBonusStats?.vit ?? 0,
                .int: levelBonusStats?.int ?? 0,
                .dex: levelBonusStats?.dex ?? 0,
                .luk: levelBonusStats?.luk ?? 0,
                .pow: levelBonusStats?.pow ?? 0,
                .sta: levelBonusStats?.sta ?? 0,
                .wis: levelBonusStats?.wis ?? 0,
                .spl: levelBonusStats?.spl ?? 0,
                .con: levelBonusStats?.con ?? 0,
                .crt: levelBonusStats?.crt ?? 0
            ]
        }
    }
}

extension JobStats: Identifiable {
    public var id: Int {
        job.rawValue
    }
}

extension JobStats: Comparable {
    public static func < (lhs: JobStats, rhs: JobStats) -> Bool {
        lhs.job.rawValue < rhs.job.rawValue
    }
}
