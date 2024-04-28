//
//  Monster.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public struct Monster: Decodable {

    /// Monster ID.
    public var id: Int

    /// Server name to reference the monster in scripts and lookups, should use no spaces.
    public var aegisName: String

    /// Name in English.
    public var name: String

    /// Name in Japanese. (Default: 'Name' value)
    public var japaneseName: String

    /// Level. (Default: 1)
    public var level: Int

    /// Total HP. (Default: 1)
    public var hp: Int

    /// Total SP. (Default: 1)
    public var sp: Int

    /// Base experience gained. (Default: 0)
    public var baseExp: Int

    /// Job experience gained. (Default: 0)
    public var jobExp: Int

    /// MVP experience gained. (Default: 0)
    public var mvpExp: Int

    /// Minimum attack in pre-renewal and base attack in renewal. (Default: 0)
    public var attack: Int

    /// Maximum attack in pre-renewal and base magic attack in renewal. (Default: 0)
    public var attack2: Int

    /// Physical defense of the monster, reduces melee and ranged physical attack/skill damage. (Default: 0)
    public var defense: Int

    /// Magic defense of the monster, reduces magical skill damage. (Default: 0)
    public var magicDefense: Int

    /// Physical resistance of the monster, reduces melee and ranged physical attack/skill damage. (Default: 0)
    public var resistance: Int

    /// Magic resistance of the monster, reduces magical skill damage. (Default: 0)
    public var magicResistance: Int

    /// Strength which affects attack. (Default: 1)
    public var str: Int

    /// Agility which affects flee. (Default: 1)
    public var agi: Int

    /// Vitality which affects defense. (Default: 1)
    public var vit: Int

    /// Intelligence which affects magic attack. (Default: 1)
    public var int: Int

    /// Dexterity which affects hit rate. (Default: 1)
    public var dex: Int

    /// Luck which affects perfect dodge/lucky flee/perfect flee/lucky dodge rate. (Default: 1)
    public var luk: Int

    /// Attack range. (Default: 0)
    public var attackRange: Int

    /// Skill cast range. (Default: 0)
    public var skillRange: Int

    /// Chase range. (Default: 0)
    public var chaseRange: Int

    /// Size. (Default: Small)
    public var size: Size

    /// Race. (Default: Formless)
    public var race: Race

    /// List of secondary groups the monster may be part of. (Optional)
    public var raceGroups: [RaceGroup]?

    /// Element. (Default: Neutral)
    public var element: Element

    /// Level of element. (Default: 1)
    public var elementLevel: Int

    /// Walk speed. (Default: DEFAULT_WALK_SPEED)
    public var walkSpeed: WalkSpeed

    /// Attack speed. (Default: 0)
    public var attackDelay: Int

    /// Attack animation speed. (Default: 0)
    public var attackMotion: Int

    /// Damage animation speed. (Default: 0)
    public var damageMotion: Int

    /// Rate at which the monster will receive incoming damage. (Default: 100)
    public var damageTaken: Int

    /// Aegis monster type AI behavior. (Default: 06)
    public var ai: MonsterAI

    /// Aegis monster class. (Default: Normal)
    public var `class`: MonsterClass

    /// List of unique behavior not defined by AI, Class, or Attribute. (Optional)
    public var modes: [MonsterMode]?

    /// List of possible MVP prize items. Max of MAX_MVP_DROP. (Optional)
    public var mvpDrops: [Drop]?

    /// List of possible normal item drops. Max of MAX_MOB_DROP. (Optional)
    public var drops: [Drop]?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case aegisName = "AegisName"
        case name = "Name"
        case japaneseName = "JapaneseName"
        case level = "Level"
        case hp = "Hp"
        case sp = "Sp"
        case baseExp = "BaseExp"
        case jobExp = "JobExp"
        case mvpExp = "MvpExp"
        case attack = "Attack"
        case attack2 = "Attack2"
        case defense = "Defense"
        case magicDefense = "MagicDefense"
        case resistance = "Resistance"
        case magicResistance = "MagicResistance"
        case str = "Str"
        case agi = "Agi"
        case vit = "Vit"
        case int = "Int"
        case dex = "Dex"
        case luk = "Luk"
        case attackRange = "AttackRange"
        case skillRange = "SkillRange"
        case chaseRange = "ChaseRange"
        case size = "Size"
        case race = "Race"
        case raceGroups = "RaceGroups"
        case element = "Element"
        case elementLevel = "ElementLevel"
        case walkSpeed = "WalkSpeed"
        case attackDelay = "AttackDelay"
        case attackMotion = "AttackMotion"
        case damageMotion = "DamageMotion"
        case damageTaken = "DamageTaken"
        case ai = "Ai"
        case `class` = "Class"
        case modes = "Modes"
        case mvpDrops = "MvpDrops"
        case drops = "Drops"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.aegisName = try container.decode(String.self, forKey: .aegisName)
        self.name = try container.decode(String.self, forKey: .name)
        self.japaneseName = try container.decodeIfPresent(String.self, forKey: .japaneseName) ?? name
        self.level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 1
        self.hp = try container.decodeIfPresent(Int.self, forKey: .hp) ?? 1
        self.sp = try container.decodeIfPresent(Int.self, forKey: .sp) ?? 1
        self.baseExp = try container.decodeIfPresent(Int.self, forKey: .baseExp) ?? 0
        self.jobExp = try container.decodeIfPresent(Int.self, forKey: .jobExp) ?? 0
        self.mvpExp = try container.decodeIfPresent(Int.self, forKey: .mvpExp) ?? 0
        self.attack = try container.decodeIfPresent(Int.self, forKey: .attack) ?? 0
        self.attack2 = try container.decodeIfPresent(Int.self, forKey: .attack2) ?? 0
        self.defense = try container.decodeIfPresent(Int.self, forKey: .defense) ?? 0
        self.magicDefense = try container.decodeIfPresent(Int.self, forKey: .magicDefense) ?? 0
        self.resistance = try container.decodeIfPresent(Int.self, forKey: .resistance) ?? 0
        self.magicResistance = try container.decodeIfPresent(Int.self, forKey: .magicResistance) ?? 0
        self.str = try container.decodeIfPresent(Int.self, forKey: .str) ?? 1
        self.agi = try container.decodeIfPresent(Int.self, forKey: .agi) ?? 1
        self.vit = try container.decodeIfPresent(Int.self, forKey: .vit) ?? 1
        self.int = try container.decodeIfPresent(Int.self, forKey: .int) ?? 1
        self.dex = try container.decodeIfPresent(Int.self, forKey: .dex) ?? 1
        self.luk = try container.decodeIfPresent(Int.self, forKey: .luk) ?? 1
        self.attackRange = try container.decodeIfPresent(Int.self, forKey: .attackRange) ?? 0
        self.skillRange = try container.decodeIfPresent(Int.self, forKey: .skillRange) ?? 0
        self.chaseRange = try container.decodeIfPresent(Int.self, forKey: .chaseRange) ?? 0
        self.size = try container.decodeIfPresent(Size.self, forKey: .size) ?? .small
        self.race = try container.decodeIfPresent(Race.self, forKey: .race) ?? .formless
        self.raceGroups = try container.decodeIfPresent(PairsNode<RaceGroup, Bool>.self, forKey: .raceGroups)?.keys
        self.element = try container.decodeIfPresent(Element.self, forKey: .element) ?? .neutral
        self.elementLevel = try container.decodeIfPresent(Int.self, forKey: .elementLevel) ?? 1
        self.walkSpeed = try container.decodeIfPresent(WalkSpeed.self, forKey: .walkSpeed) ?? .default
        self.attackDelay = try container.decodeIfPresent(Int.self, forKey: .attackDelay) ?? 0
        self.attackMotion = try container.decodeIfPresent(Int.self, forKey: .attackMotion) ?? 0
        self.damageMotion = try container.decodeIfPresent(Int.self, forKey: .damageMotion) ?? 0
        self.damageTaken = try container.decodeIfPresent(Int.self, forKey: .damageTaken) ?? 100
        self.ai = try container.decodeIfPresent(MonsterAI.self, forKey: .ai) ?? .ai06
        self.class = try container.decodeIfPresent(MonsterClass.self, forKey: .class) ?? .normal
        self.modes = try container.decodeIfPresent(PairsNode<MonsterMode, Bool>.self, forKey: .modes)?.keys
        self.mvpDrops = try container.decodeIfPresent([Monster.Drop].self, forKey: .mvpDrops)
        self.drops = try container.decodeIfPresent([Monster.Drop].self, forKey: .drops)
    }
}

extension Monster {

    /// Walk speed.
    public struct WalkSpeed: RawRepresentable, Decodable {

        public var rawValue: Int

        /// DEFAULT_WALK_SPEED
        public static let `default` = WalkSpeed(rawValue: 150)

        /// MIN_WALK_SPEED
        public static let min = WalkSpeed(rawValue: 20)

        /// MAX_WALK_SPEED
        public static let max = WalkSpeed(rawValue: 1000)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension Monster {

    /// Item of the monster drop.
    public struct Drop: Decodable {

        /// Item name.
        public var item: String

        /// Drop rate of item.
        public var rate: Int

        /// If the item is shielded from TF_STEAL. (Default: false)
        public var stealProtected: Bool

        /// Random Option Group applied to item on drop. (Default: None)
        public var randomOptionGroup: String?

        /// Index used for overwriting item. (Optional)
        public var index: Int?

        enum CodingKeys: String, CodingKey {
            case item = "Item"
            case rate = "Rate"
            case stealProtected = "StealProtected"
            case randomOptionGroup = "RandomOptionGroup"
            case index = "Index"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.item = try container.decode(String.self, forKey: .item)
            self.rate = try container.decode(Int.self, forKey: .rate)
            self.stealProtected = try container.decodeIfPresent(Bool.self, forKey: .stealProtected) ?? false
            self.randomOptionGroup = try container.decodeIfPresent(String.self, forKey: .randomOptionGroup)
            self.index = try container.decodeIfPresent(Int.self, forKey: .index)
        }
    }
}

extension Monster: Identifiable {
}

extension Monster: Equatable {
    public static func == (lhs: Monster, rhs: Monster) -> Bool {
        lhs.id == rhs.id
    }
}

extension Monster: Comparable {
    public static func < (lhs: Monster, rhs: Monster) -> Bool {
        lhs.id < rhs.id
    }
}

extension Monster: Hashable {
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
