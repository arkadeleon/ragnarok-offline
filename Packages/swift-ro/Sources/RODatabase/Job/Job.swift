//
//  Job.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/11.
//

import ROConstants

public struct Job: Equatable, Hashable, Identifiable, Sendable {

    /// Job ID.
    public var id: JobID

    /// Base maximum weight. (Default: 20000)
    public var maxWeight: Int

    /// Exponential HP increase. Per base level: [HpFactor * BaseLv / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 0)
    public var hpFactor: Int

    /// Linear HP increase. Per base level: [HpIncrease / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 500)
    public var hpIncrease: Int

    /// Exponential SP increase. Per base level: [SpFactor * BaseLv / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 0)
    public var spFactor: Int

    /// Linear SP increase. Per base level: [SpIncrease / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 100)
    public var spIncrease: Int

    /// Exponential AP increase. Per base level: [ApFactor * BaseLv / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 0)
    public var apFactor: Int

    /// Linear AP increase. Per base level: [ApIncrease / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 0)
    public var apIncrease: Int

    /// Base ASPD for each weapon type. (Default: 2000)
    public var baseASPD: [WeaponType : Int]

    /// Job level bonus stats/traits.
    public var bonusStats: [Int : [Parameter : Int]]

    /// Maximum stats/traits applicable. (Default: battle_config::max_*_parameter)
    public var maxStats: [Parameter : Int]?

    /// Maximum base level. (Default: MAX_LEVEL)
    public var maxBaseLevel: Int?

    /// Base experience per level.
    public var baseExp: [Int : Int]

    /// Maximum job level. (Default: MAX_LEVEL)
    public var maxJobLevel: Int?

    /// Job experience per level.
    public var jobExp: [Int : Int]

    /// Base HP per base level.
    public var baseHp: [Int : Int]

    /// Base SP per base level.
    public var baseSp: [Int : Int]

    /// Base AP per base level.
    public var baseAp: [Int : Int]

    init?(jobID: JobID, basicStatsList: [JobBasicStats], aspdStatsList: [JobASPDStats], expStatsList: [JobExpStats], basePointsStatsList: [JobBasePointsStats]) {
        guard let basicStats = basicStatsList.first(where: { $0.jobs.contains(jobID) }),
              let aspdStats = aspdStatsList.first(where: { $0.jobs.contains(jobID) }),
              let baseExpStats = expStatsList.first(where: { $0.jobs.contains(jobID) && !$0.baseExp.isEmpty }),
              let jobExpStats = expStatsList.first(where: { $0.jobs.contains(jobID) && !$0.jobExp.isEmpty }),
              let baseHpPointsStats = basePointsStatsList.first(where: { $0.jobs.contains(jobID) && !$0.baseHp.isEmpty }),
              let baseSpPointsStats = basePointsStatsList.first(where: { $0.jobs.contains(jobID) && !$0.baseSp.isEmpty })
        else {
            logger.info("Failed to init Job for \(jobID.stringValue)")
            return nil
        }

        self.id = jobID

        self.maxWeight = basicStats.maxWeight
        self.hpFactor = basicStats.hpFactor
        self.hpIncrease = basicStats.hpIncrease
        self.spFactor = basicStats.spFactor
        self.spIncrease = basicStats.spIncrease
        self.apFactor = basicStats.apFactor
        self.apIncrease = basicStats.apIncrease

        self.baseASPD = aspdStats.baseASPD

        self.maxBaseLevel = baseExpStats.maxBaseLevel

        let baseExp = baseExpStats.baseExp.map({ ($0.level, $0.exp) })
        self.baseExp = Dictionary(baseExp, uniquingKeysWith: { (_, last) in last })

        self.maxJobLevel = jobExpStats.maxJobLevel

        let jobExp = jobExpStats.jobExp.map({ ($0.level, $0.exp) })
        self.jobExp = Dictionary(jobExp, uniquingKeysWith: { (_, last) in last })

        let baseHp = baseHpPointsStats.baseHp.map({ ($0.level, $0.hp) })
        self.baseHp = Dictionary(baseHp, uniquingKeysWith: { (_, last) in last })

        let baseSp = baseSpPointsStats.baseSp.map({ ($0.level, $0.sp) })
        self.baseSp = Dictionary(baseSp, uniquingKeysWith: { (_, last) in last })

        let baseAp = baseSpPointsStats.baseAp.map({ ($0.level, $0.ap) })
        self.baseAp = Dictionary(baseAp, uniquingKeysWith: { (_, last) in last })

        let bonusStats = basicStats.bonusStats.map {
            var stats: [Parameter : Int] = [:]
            stats[.str] = $0.str
            stats[.agi] = $0.agi
            stats[.vit] = $0.vit
            stats[.int] = $0.int
            stats[.dex] = $0.dex
            stats[.luk] = $0.luk
            stats[.pow] = $0.pow
            stats[.sta] = $0.sta
            stats[.wis] = $0.wis
            stats[.spl] = $0.spl
            stats[.con] = $0.con
            stats[.crt] = $0.crt
            return ($0.level, stats)
        }
        self.bonusStats = Dictionary(bonusStats, uniquingKeysWith: { (_, last) in last })
    }
}

extension Job: Comparable {
    public static func < (lhs: Job, rhs: Job) -> Bool {
        lhs.id.rawValue < rhs.id.rawValue
    }
}
