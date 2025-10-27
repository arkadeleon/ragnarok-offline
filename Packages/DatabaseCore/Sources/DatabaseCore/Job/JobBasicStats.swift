//
//  JobBasicStats.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/1/10.
//

import RagnarokConstants

struct JobBasicStats: Decodable {

    /// List of jobs associated to group.
    var jobs: Set<JobID>

    /// Base maximum weight. (Default: 20000)
    var maxWeight: Int

    /// Exponential HP increase. Per base level: [HpFactor * BaseLv / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 0)
    var hpFactor: Int

    /// Linear HP increase. Per base level: [HpIncrease / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 500)
    var hpIncrease: Int

    /// Exponential SP increase. Per base level: [SpFactor * BaseLv / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 0)
    var spFactor: Int

    /// Linear SP increase. Per base level: [SpIncrease / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 100)
    var spIncrease: Int

    /// Exponential AP increase. Per base level: [ApFactor * BaseLv / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 0)
    var apFactor: Int

    /// Linear AP increase. Per base level: [ApIncrease / 100]. Used when macro HP_SP_TABLES is disabled. (Default: 0)
    var apIncrease: Int

    /// Job level bonus stats/traits.
    var bonusStats: [LevelBonusStats]

    enum CodingKeys: String, CodingKey {
        case jobs = "Jobs"
        case maxWeight = "MaxWeight"
        case hpFactor = "HpFactor"
        case hpIncrease = "HpIncrease"
        case spFactor = "SpFactor"
        case spIncrease = "SpIncrease"
        case apFactor = "ApFactor"
        case apIncrease = "ApIncrease"
        case bonusStats = "BonusStats"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.jobs = try container.decode([JobID : Bool].self, forKey: .jobs).unorderedKeys
        self.maxWeight = try container.decodeIfPresent(Int.self, forKey: .maxWeight) ?? 20000
        self.hpFactor = try container.decodeIfPresent(Int.self, forKey: .hpFactor) ?? 0
        self.hpIncrease = try container.decodeIfPresent(Int.self, forKey: .hpIncrease) ?? 500
        self.spFactor = try container.decodeIfPresent(Int.self, forKey: .spFactor) ?? 0
        self.spIncrease = try container.decodeIfPresent(Int.self, forKey: .spIncrease) ?? 100
        self.apFactor = try container.decodeIfPresent(Int.self, forKey: .apFactor) ?? 0
        self.apIncrease = try container.decodeIfPresent(Int.self, forKey: .apIncrease) ?? 0
        self.bonusStats = try container.decodeIfPresent([LevelBonusStats].self, forKey: .bonusStats) ?? []
    }
}

extension JobBasicStats {

    struct LevelBonusStats: Decodable {

        /// Job level.
        var level: Int

        /// Stength increase amount. (Default: 0)
        var str: Int

        /// Agility increase amount. (Default: 0)
        var agi: Int

        /// Vitality increase amount. (Default: 0)
        var vit: Int

        /// Intelligence increase amount. (Default: 0)
        var int: Int

        /// Dexterity increase amount. (Default: 0)
        var dex: Int

        /// Luck increase amount. (Default: 0)
        var luk: Int

        /// Power increase amount. (Default: 0)
        var pow: Int

        /// Stamina increase amount. (Default: 0)
        var sta: Int

        /// Wisdom increase amount. (Default: 0)
        var wis: Int

        /// Spell increase amount. (Default: 0)
        var spl: Int

        /// Concentration increase amount. (Default: 0)
        var con: Int

        /// Creative increase amount. (Default: 0)
        var crt: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case str = "Str"
            case agi = "Agi"
            case vit = "Vit"
            case int = "Int"
            case dex = "Dex"
            case luk = "Luk"
            case pow = "Pow"
            case sta = "Sta"
            case wis = "Wis"
            case spl = "Spl"
            case con = "Con"
            case crt = "Crt"
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.level = try container.decode(Int.self, forKey: .level)
            self.str = try container.decodeIfPresent(Int.self, forKey: .str) ?? 0
            self.agi = try container.decodeIfPresent(Int.self, forKey: .agi) ?? 0
            self.vit = try container.decodeIfPresent(Int.self, forKey: .vit) ?? 0
            self.int = try container.decodeIfPresent(Int.self, forKey: .int) ?? 0
            self.dex = try container.decodeIfPresent(Int.self, forKey: .dex) ?? 0
            self.luk = try container.decodeIfPresent(Int.self, forKey: .luk) ?? 0
            self.pow = try container.decodeIfPresent(Int.self, forKey: .pow) ?? 0
            self.sta = try container.decodeIfPresent(Int.self, forKey: .sta) ?? 0
            self.wis = try container.decodeIfPresent(Int.self, forKey: .wis) ?? 0
            self.spl = try container.decodeIfPresent(Int.self, forKey: .spl) ?? 0
            self.con = try container.decodeIfPresent(Int.self, forKey: .con) ?? 0
            self.crt = try container.decodeIfPresent(Int.self, forKey: .crt) ?? 0
        }
    }
}
