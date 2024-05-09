//
//  MonsterSummon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

public struct MonsterSummon: Decodable, Equatable, Hashable {

    /// Monster random group name. "MOBG_" is appended to the name during the parsing.
    public var group: String

    /// Monster AegisName summoned by default when the summon fails.
    public var `default`: String

    /// List of Summonable Monsters.
    public var summon: [Summon]

    enum CodingKeys: String, CodingKey {
        case group = "Group"
        case `default` = "Default"
        case summon = "Summon"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.group = try container.decode(String.self, forKey: .group)
        self.default = try container.decode(String.self, forKey: .default)
        self.summon = try container.decode([Summon].self, forKey: .summon)
    }
}

extension MonsterSummon {

    /// Summonable Monster.
    public struct Summon: Decodable, Equatable, Hashable {

        /// Monster AegisName.
        public var monster: String

        /// Summon rate of Mob (from [0-1000000]).
        public var rate: Int

        enum CodingKeys: String, CodingKey {
            case monster = "Mob"
            case rate = "Rate"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.monster = try container.decode(String.self, forKey: .monster)
            self.rate = try container.decode(Int.self, forKey: .rate)
        }
    }
}
