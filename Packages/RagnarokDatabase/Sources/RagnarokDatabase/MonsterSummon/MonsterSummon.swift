//
//  MonsterSummon.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/5/9.
//

public struct MonsterSummon: Decodable, Equatable, Hashable, Sendable {

    /// Monster random group name. "MOBG_" is appended to the name during the parsing.
    public var group: String

    /// Monster AegisName summoned by default when the summon fails.
    public var `default`: String

    /// List of Summonable Monsters.
    public var summon: [MonsterSummon.Summon]

    enum CodingKeys: String, CodingKey {
        case group = "Group"
        case `default` = "Default"
        case summon = "Summon"
    }
}

extension MonsterSummon {

    /// Summonable Monster.
    public struct Summon: Decodable, Equatable, Hashable, Sendable {

        /// Monster AegisName.
        public var monster: String

        /// Summon rate of Mob (from [0-1000000]).
        public var rate: Int

        enum CodingKeys: String, CodingKey {
            case monster = "Mob"
            case rate = "Rate"
        }
    }
}
