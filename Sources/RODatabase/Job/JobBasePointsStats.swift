//
//  JobBasePointsStats.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

struct JobBasePointsStats: Decodable {

    /// List of jobs associated to group.
    var jobs: [Job]

    /// Base HP per base level.
    var baseHp: [LevelBaseHp]

    /// Base SP per base level.
    var baseSp: [LevelBaseSp]

    /// Base AP per base level.
    var baseAp: [LevelBaseAp]

    enum CodingKeys: String, CodingKey {
        case jobs = "Jobs"
        case baseHp = "BaseHp"
        case baseSp = "BaseSp"
        case baseAp = "BaseAp"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jobs = try container.decode(PairsNode<Job, Bool>.self, forKey: .jobs).keys
        self.baseHp = try container.decodeIfPresent([LevelBaseHp].self, forKey: .baseHp) ?? []
        self.baseSp = try container.decodeIfPresent([LevelBaseSp].self, forKey: .baseSp) ?? []
        self.baseAp = try container.decodeIfPresent([LevelBaseAp].self, forKey: .baseAp) ?? []
    }
}

extension JobBasePointsStats {

    struct LevelBaseHp: Decodable {

        /// Base level.
        var level: Int

        /// Base HP.
        var hp: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case hp = "Hp"
        }
    }
}

extension JobBasePointsStats {

    struct LevelBaseSp: Decodable {

        /// Base level.
        var level: Int

        /// Base SP.
        var sp: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case sp = "Sp"
        }
    }
}

extension JobBasePointsStats {

    struct LevelBaseAp: Decodable {

        /// Base level.
        var level: Int

        /// Base AP.
        var ap: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case ap = "Ap"
        }
    }
}
