//
//  Skill.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/1/11.
//

import RagnarokConstants

public struct Skill: Decodable, Equatable, Hashable, Identifiable, Sendable {

    /// Unique skill ID.
    public var id: Int

    /// Skill Aegis name.
    public var aegisName: String

    /// Skill description.
    public var name: String

    /// Max skill level.
    public var maxLevel: Int

    /// Skill type. (Default: None)
    public var type: BattleFlag

    /// Skill target type. (Default: Passive)
    public var targetType: SkillInfoFlag

    /// Skill damage properties.
    public var damageFlags: Set<SkillDamageFlag>

    /// Skill information flags.
    public var flags: Set<SkillInfoFlag2>

    /// Skill range. (Default: 0)
    public var range: EitherNode<Int, [Int]>

    /// Skill hit type. (Default: Normal)
    public var hit: DamageType

    /// Skill hit count. (Default: 0)
    public var hitCount: EitherNode<Int, [Int]>

    /// Skill element. (Default: Neutral)
    public var element: EitherNode<Element, [Element]>

    /// Skill splash area of effect. (Default: 0)
    public var splashArea: EitherNode<Int, [Int]>

    /// Maximum amount of active skill instances that can be on the ground. (Default: 0)
    public var activeInstance: EitherNode<Int, [Int]>

    /// Amount of tiles the skill knockbacks. (Default: 0)
    public var knockback: EitherNode<Int, [Int]>

    /// Gives AP on successful skill cast. (Default: 0)
    public var giveAp: EitherNode<Int, [Int]>

    /// Determines if the skill is copyable. (Optional)
    public var copyFlags: CopyFlags?

    /// Determines if the skill can be used near a NPC. (Optional)
    public var noNearNPC: NoNearNPC?

    /// Cancel cast when hit. (Default: false)
    public var castCancel: Bool

    /// Defense reduction rate during skill cast. (Default: 0)
    public var castDefenseReduction: Int

    /// Time to cast the skill in milliseconds. (Default: 0)
    public var castTime: EitherNode<Int, [Int]>

    /// Time the character cannot use skills in milliseconds. (Default: 0)
    public var afterCastActDelay: EitherNode<Int, [Int]>

    /// Time before the character can move again in milliseconds. (Default: 0)
    public var afterCastWalkDelay: EitherNode<Int, [Int]>

    /// Duration of the skill in milliseconds. (Default: 0)
    public var duration1: EitherNode<Int, [Int]>

    /// Duration of the skill in milliseconds. (Default: 0)
    public var duration2: EitherNode<Int, [Int]>

    /// Time before the character can use the same skill again in milliseconds. (Default: 0)
    public var cooldown: EitherNode<Int, [Int]>

    /// Time that is fixed during cast of the skill in milliseconds. (Default: 0)
    public var fixedCastTime: EitherNode<Int, [Int]>

    /// Effects of the skill's cast time. (Optional)
    public var castTimeFlags: Set<SkillCastFlag>?

    /// Effects of the skill's delay. (Optional)
    public var castDelayFlags: Set<SkillCastFlag>?

    /// List of requirements to cast the skill. (Optional)
    public var requires: Requires?

    /// Skill unit values. (Optional)
    public var unit: Unit?

    /// Status Change that is associated to the skill. (Optional)
    public var status: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case aegisName = "Name"
        case name = "Description"
        case maxLevel = "MaxLevel"
        case type = "Type"
        case targetType = "TargetType"
        case damageFlags = "DamageFlags"
        case flags = "Flags"
        case range = "Range"
        case hit = "Hit"
        case hitCount = "HitCount"
        case element = "Element"
        case splashArea = "SplashArea"
        case activeInstance = "ActiveInstance"
        case knockback = "Knockback"
        case giveAp = "GiveAp"
        case copyFlags = "CopyFlags"
        case noNearNPC = "NoNearNPC"
        case castCancel = "CastCancel"
        case castDefenseReduction = "CastDefenseReduction"
        case castTime = "CastTime"
        case afterCastActDelay = "AfterCastActDelay"
        case afterCastWalkDelay = "AfterCastWalkDelay"
        case duration1 = "Duration1"
        case duration2 = "Duration2"
        case cooldown = "Cooldown"
        case fixedCastTime = "FixedCastTime"
        case castTimeFlags = "CastTimeFlags"
        case castDelayFlags = "CastDelayFlags"
        case requires = "Requires"
        case unit = "Unit"
        case status = "Status"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.aegisName = try container.decode(String.self, forKey: .aegisName)
        self.name = try container.decode(String.self, forKey: .name)
        self.maxLevel = try container.decode(Int.self, forKey: .maxLevel)
        self.type = try container.decodeIfPresent(BattleFlag.self, forKey: .type) ?? .none
        self.targetType = try container.decodeIfPresent(SkillInfoFlag.self, forKey: .targetType) ?? .passive
        self.damageFlags = try container.decodeIfPresent([SkillDamageFlag : Bool].self, forKey: .damageFlags)?.unorderedKeys ?? []
        self.flags = try container.decodeIfPresent([SkillInfoFlag2 : Bool].self, forKey: .flags)?.unorderedKeys ?? []
        self.range = try container.decodeIfPresent(EitherNode<Int, [LevelRange]>.self, forKey: .range)?.mapRight { $0.map { $0.range } } ?? .left(0)
        self.hit = try container.decodeIfPresent(DamageType.self, forKey: .hit) ?? .normal
        self.hitCount = try container.decodeIfPresent(EitherNode<Int, [LevelHitCount]>.self, forKey: .hitCount)?.mapRight { $0.map { $0.hitCount } } ?? .left(0)
        self.element = try container.decodeIfPresent(EitherNode<Element, [LevelElement]>.self, forKey: .element)?.mapRight { $0.map { $0.element } } ?? .left(.neutral)
        self.splashArea = try container.decodeIfPresent(EitherNode<Int, [LevelSplashArea]>.self, forKey: .splashArea)?.mapRight { $0.map { $0.splashArea } } ?? .left(0)
        self.activeInstance = try container.decodeIfPresent(EitherNode<Int, [LevelActiveInstance]>.self, forKey: .activeInstance)?.mapRight { $0.map { $0.activeInstance } } ?? .left(0)
        self.knockback = try container.decodeIfPresent(EitherNode<Int, [LevelKnockback]>.self, forKey: .knockback)?.mapRight { $0.map { $0.knockback } } ?? .left(0)
        self.giveAp = try container.decodeIfPresent(EitherNode<Int, [LevelGiveAp]>.self, forKey: .giveAp)?.mapRight { $0.map { $0.giveAp } } ?? .left(0)
        self.copyFlags = try container.decodeIfPresent(CopyFlags.self, forKey: .copyFlags)
        self.noNearNPC = try container.decodeIfPresent(NoNearNPC.self, forKey: .noNearNPC)
        self.castCancel = try container.decodeIfPresent(Bool.self, forKey: .castCancel) ?? true
        self.castDefenseReduction = try container.decodeIfPresent(Int.self, forKey: .castDefenseReduction) ?? 0
        self.castTime = try container.decodeIfPresent(EitherNode<Int, [LevelCastTime]>.self, forKey: .castTime)?.mapRight { $0.map { $0.caseTime } } ?? .left(0)
        self.afterCastActDelay = try container.decodeIfPresent(EitherNode<Int, [LevelAfterCastActDelay]>.self, forKey: .afterCastActDelay)?.mapRight { $0.map { $0.afterCastActDelay } } ?? .left(0)
        self.afterCastWalkDelay = try container.decodeIfPresent(EitherNode<Int, [LevelAfterCastWalkDelay]>.self, forKey: .afterCastWalkDelay)?.mapRight { $0.map { $0.afterCastWalkDelay } } ?? .left(0)
        self.duration1 = try container.decodeIfPresent(EitherNode<Int, [LevelDuration]>.self, forKey: .duration1)?.mapRight { $0.map { $0.duration } } ?? .left(0)
        self.duration2 = try container.decodeIfPresent(EitherNode<Int, [LevelDuration]>.self, forKey: .duration2)?.mapRight { $0.map { $0.duration } } ?? .left(0)
        self.cooldown = try container.decodeIfPresent(EitherNode<Int, [LevelCooldown]>.self, forKey: .cooldown)?.mapRight { $0.map { $0.cooldown } } ?? .left(0)
        self.fixedCastTime = try container.decodeIfPresent(EitherNode<Int, [LevelFixedCastTime]>.self, forKey: .fixedCastTime)?.mapRight { $0.map { $0.fixedCastTime } } ?? .left(0)
        self.castTimeFlags = try container.decodeIfPresent([SkillCastFlag : Bool].self, forKey: .castTimeFlags)?.unorderedKeys
        self.castDelayFlags = try container.decodeIfPresent([SkillCastFlag : Bool].self, forKey: .castDelayFlags)?.unorderedKeys
        self.requires = try container.decodeIfPresent(Requires.self, forKey: .requires)
        self.unit = try container.decodeIfPresent(Unit.self, forKey: .unit)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
    }
}

extension Skill {

    struct LevelRange: Decodable {

        /// Skill level.
        var level: Int

        /// Range at specific skill level.
        var range: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case range = "Size"
        }
    }

    struct LevelHitCount: Decodable {

        /// Skill level.
        var level: Int

        /// Number of hits at specific skill level.
        var hitCount: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case hitCount = "Count"
        }
    }

    struct LevelElement: Decodable {

        /// Skill level.
        var level: Int

        /// Element at specific skill level.
        var element: Element

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case element = "Element"
        }
    }

    struct LevelSplashArea: Decodable {

        /// Skill level.
        var level: Int

        /// Splash area at specific skill level.
        var splashArea: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case splashArea = "Area"
        }
    }

    struct LevelActiveInstance: Decodable {

        /// Skill level.
        var level: Int

        /// Active instances at specific skill level.
        var activeInstance: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case activeInstance = "Max"
        }
    }

    struct LevelKnockback: Decodable {

        /// Skill level.
        var level: Int

        /// Knockback count at specific skill level.
        var knockback: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case knockback = "Amount"
        }
    }

    struct LevelGiveAp: Decodable {

        /// Skill level.
        var level: Int

        /// AP gained at specific skill level.
        var giveAp: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case giveAp = "Amount"
        }
    }

    struct LevelCastTime: Decodable {

        /// Skill level.
        var level: Int

        /// Cast time at specific skill level in milliseconds.
        var caseTime: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case caseTime = "Time"
        }
    }

    struct LevelAfterCastActDelay: Decodable {

        /// Skill level.
        var level: Int

        /// After cast action delay at specific skill level in milliseconds.
        var afterCastActDelay: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case afterCastActDelay = "Time"
        }
    }

    struct LevelAfterCastWalkDelay: Decodable {

        /// Skill level.
        var level: Int

        /// After cast walk delay at specific skill level in milliseconds.
        var afterCastWalkDelay: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case afterCastWalkDelay = "Time"
        }
    }

    struct LevelDuration: Decodable {

        /// Skill level.
        var level: Int

        /// Skill duration at specific skill level in milliseconds.
        var duration: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case duration = "Time"
        }
    }

    struct LevelCooldown: Decodable {

        /// Skill level.
        var level: Int

        /// Cooldown at specific skill level in milliseconds.
        var cooldown: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case cooldown = "Time"
        }
    }

    struct LevelFixedCastTime: Decodable {

        /// Skill level.
        var level: Int

        /// After cast action delay at specific skill level in milliseconds.
        var fixedCastTime: Int

        enum CodingKeys: String, CodingKey {
            case level = "Level"
            case fixedCastTime = "Time"
        }
    }
}

extension Skill {

    public struct CopyFlags: Decodable, Equatable, Hashable, Sendable {

        /// Type of skill that can copy.
        public var skill: Set<SkillCopyableOption>

        /// Remove a requirement type. (Optional)
        public var removeRequirement: Set<SkillRequirement>?

        enum CodingKeys: String, CodingKey {
            case skill = "Skill"
            case removeRequirement = "RemoveRequirement"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.skill = try container.decodeIfPresent([SkillCopyableOption : Bool].self, forKey: .skill)?.unorderedKeys ?? []
            self.removeRequirement = try container.decodeIfPresent([SkillRequirement : Bool].self, forKey: .removeRequirement)?.unorderedKeys
        }
    }
}

extension Skill {

    public struct NoNearNPC: Decodable, Equatable, Hashable, Sendable {

        /// Number of cells from an NPC where the skill can be cast.
        /// If zero this will read the splash range value.
        /// If that is also zero then Unit Range + Unit Layout Range will be used.
        public var additionalRange: Int?

        /// Type of NPC that will block the skill.
        public var type: Set<SkillNoNearNPC>

        enum CodingKeys: String, CodingKey {
            case additionalRange = "AdditionalRange"
            case type = "Type"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.additionalRange = try container.decodeIfPresent(Int.self, forKey: .additionalRange)
            self.type = try container.decodeIfPresent([SkillNoNearNPC : Bool].self, forKey: .type)?.unorderedKeys ?? []
        }
    }
}

extension Skill {

    public struct Requires: Decodable, Equatable, Hashable, Sendable {

        /// HP required to cast. (Default: 0)
        public var hpCost: EitherNode<Int, [Int]>

        /// SP required to cast. (Default: 0)
        public var spCost: EitherNode<Int, [Int]>

        /// AP required to cast. (Default: 0)
        public var apCost: EitherNode<Int, [Int]>

        /// HP rate required to cast. If positive, uses current HP, else uses Max HP. (Default: 0)
        public var hpRateCost: EitherNode<Int, [Int]>

        /// SP rate required to cast. If positive, uses current SP, else uses Max SP. (Default: 0)
        public var spRateCost: EitherNode<Int, [Int]>

        /// AP rate required to cast. If positive, uses current AP, else uses Max AP. (Default: 0)
        public var apRateCost: EitherNode<Int, [Int]>

        /// Maximum amount of HP to cast the skill. (Default: 0)
        public var maxHpTrigger: EitherNode<Int, [Int]>

        /// Zeny required to cast. (Default: 0)
        public var zenyCost: EitherNode<Int, [Int]>

        /// Weapon required to cast. (Default: All)
        public var weapon: Set<WeaponType>

        /// Ammo required to cast. (Default: None)
        public var ammo: Set<AmmoType>

        /// Ammo amount required to cast. (Default: 0)
        public var ammoAmount: EitherNode<Int, [Int]>

        /// Special state required to cast. (Default: None)
        public var state: SkillStateRequirement

        /// Status change required to cast. (Default: nullptr)
        public var status: [String]

        /// Spirit sphere required to cast. (Default: 0)
        public var spiritSphereCost: EitherNode<Int, [Int]>

        /// Item required to cast. (Default: 0)
        public var itemCost: [LevelItemCost]

        /// Equipped item required to cast. (Default: nullptr)
        public var equipment: [String]

        struct LevelHpCost: Decodable {

            /// Skill level.
            var level: Int

            /// HP required at specific skill level.
            var hpCost: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case hpCost = "Amount"
            }
        }

        struct LevelSpCost: Decodable {

            /// Skill level.
            var level: Int

            /// SP required at specific skill level.
            var spCost: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case spCost = "Amount"
            }
        }

        struct LevelApCost: Decodable {

            /// Skill level.
            var level: Int

            /// AP required at specific skill level.
            var apCost: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case apCost = "Amount"
            }
        }

        struct LevelHpRateCost: Decodable {

            /// Skill level.
            var level: Int

            /// HP rate required at specific skill level.
            var hpRateCost: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case hpRateCost = "Amount"
            }
        }

        struct LevelSpRateCost: Decodable {

            /// Skill level.
            var level: Int

            /// SP rate required at specific skill level.
            var spRateCost: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case spRateCost = "Amount"
            }
        }

        struct LevelApRateCost: Decodable {

            /// Skill level.
            var level: Int

            /// AP rate required at specific skill level.
            var apRateCost: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case apRateCost = "Amount"
            }
        }

        struct LevelMaxHpTrigger: Decodable {

            /// Skill level.
            var level: Int

            /// Maximum HP trigger required at specific skill level.
            var maxHpTrigger: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case maxHpTrigger = "Amount"
            }
        }

        struct LevelZenyCost: Decodable {

            /// Skill level.
            var level: Int

            /// Zeny required at specific skill level.
            var zenyCost: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case zenyCost = "Amount"
            }
        }

        struct LevelAmmoAmount: Decodable {

            /// Skill level.
            var level: Int

            /// Ammo amount required at specific skill level.
            var ammoAmount: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case ammoAmount = "Amount"
            }
        }

        struct LevelSpiritSphereCost: Decodable {

            /// Skill level.
            var level: Int

            /// Spirit sphere required at specific skill level.
            var spiritSphereCost: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case spiritSphereCost = "Amount"
            }
        }

        public struct LevelItemCost: Decodable, Equatable, Hashable, Sendable {

            /// Item name.
            var item: String

            /// Item amount.
            var amount: Int

            /// Skill level. Makes the skill item check become level dependent if supplied. (Default: applies to all levels)
            var level: Int?

            enum CodingKeys: String, CodingKey {
                case item = "Item"
                case amount = "Amount"
                case level = "Level"
            }
        }

        enum CodingKeys: String, CodingKey {
            case hpCost = "HpCost"
            case spCost = "SpCost"
            case apCost = "ApCost"
            case hpRateCost = "HpRateCost"
            case spRateCost = "SpRateCost"
            case apRateCost = "ApRateCost"
            case maxHpTrigger = "MaxHpTrigger"
            case zenyCost = "ZenyCost"
            case weapon = "Weapon"
            case ammo = "Ammo"
            case ammoAmount = "AmmoAmount"
            case state = "State"
            case status = "Status"
            case spiritSphereCost = "SpiritSphereCost"
            case itemCost = "ItemCost"
            case equipment = "Equipment"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.hpCost = try container.decodeIfPresent(EitherNode<Int, [LevelHpCost]>.self, forKey: .hpCost)?.mapRight { $0.map { $0.hpCost } } ?? .left(0)
            self.spCost = try container.decodeIfPresent(EitherNode<Int, [LevelSpCost]>.self, forKey: .spCost)?.mapRight { $0.map { $0.spCost } } ?? .left(0)
            self.apCost = try container.decodeIfPresent(EitherNode<Int, [LevelApCost]>.self, forKey: .apCost)?.mapRight { $0.map { $0.apCost } } ?? .left(0)
            self.hpRateCost = try container.decodeIfPresent(EitherNode<Int, [LevelHpRateCost]>.self, forKey: .hpRateCost)?.mapRight { $0.map { $0.hpRateCost } } ?? .left(0)
            self.spRateCost = try container.decodeIfPresent(EitherNode<Int, [LevelSpRateCost]>.self, forKey: .spRateCost)?.mapRight { $0.map { $0.spRateCost } } ?? .left(0)
            self.apRateCost = try container.decodeIfPresent(EitherNode<Int, [LevelApRateCost]>.self, forKey: .apRateCost)?.mapRight { $0.map { $0.apRateCost } } ?? .left(0)
            self.maxHpTrigger = try container.decodeIfPresent(EitherNode<Int, [LevelMaxHpTrigger]>.self, forKey: .maxHpTrigger)?.mapRight { $0.map { $0.maxHpTrigger } } ?? .left(0)
            self.zenyCost = try container.decodeIfPresent(EitherNode<Int, [LevelZenyCost]>.self, forKey: .zenyCost)?.mapRight { $0.map { $0.zenyCost } } ?? .left(0)
            self.weapon = try container.decodeIfPresent([WeaponType : Bool].self, forKey: .weapon)?.unorderedKeys ?? []
            self.ammo = try container.decodeIfPresent([AmmoType : Bool].self, forKey: .ammo)?.unorderedKeys ?? []
            self.ammoAmount = try container.decodeIfPresent(EitherNode<Int, [LevelAmmoAmount]>.self, forKey: .ammoAmount)?.mapRight { $0.map { $0.ammoAmount } } ?? .left(0)
            self.state = try container.decodeIfPresent(SkillStateRequirement.self, forKey: .state) ?? .none
            self.status = try container.decodeIfPresent([String : Bool].self, forKey: .status)?.keys.map({ $0 }) ?? []
            self.spiritSphereCost = try container.decodeIfPresent(EitherNode<Int, [LevelSpiritSphereCost]>.self, forKey: .spiritSphereCost)?.mapRight { $0.map { $0.spiritSphereCost } } ?? .left(0)
            self.itemCost = try container.decodeIfPresent([LevelItemCost].self, forKey: .itemCost) ?? []
            self.equipment = try container.decodeIfPresent([String : Bool].self, forKey: .equipment)?.keys.map({ $0 }) ?? []
        }
    }
}

extension Skill {

    public struct Unit: Decodable, Equatable, Hashable, Sendable {

        /// Skill unit ID.
        public var id: SkillUnitID

        /// Alternate skill unit ID. (Default: 0)
        public var alternateId: SkillUnitID?

        /// Skill unit layout. (Default: 0)
        public var layout: EitherNode<Int, [Int]>

        /// Skill unit range. (Default: 0)
        public var range: EitherNode<Int, [Int]>

        /// Skill unit interval in milliseconds. (Default: 0)
        public var interval: Int

        /// Skill unit target type. (Default: All)
        public var target: BattleCheckTarget

        /// Skill unit flags. (Default: None)
        public var flag: Set<SkillUnitFlag>

        struct LevelLayout: Decodable {

            /// Skill level.
            var level: Int

            /// Unit layout at specific skill level.
            var layout: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case layout = "Size"
            }
        }

        struct LevelRange: Decodable {

            /// Skill level.
            var level: Int

            /// Unit range at specific skill level.
            var range: Int

            enum CodingKeys: String, CodingKey {
                case level = "Level"
                case range = "Size"
            }
        }

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case alternateId = "AlternateId"
            case layout = "Layout"
            case range = "Range"
            case interval = "Interval"
            case target = "Target"
            case flag = "Flag"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(SkillUnitID.self, forKey: .id)
            self.alternateId = try container.decodeIfPresent(SkillUnitID.self, forKey: .alternateId)
            self.layout = try container.decodeIfPresent(EitherNode<Int, [LevelLayout]>.self, forKey: .layout)?.mapRight { $0.map { $0.layout } } ?? .left(0)
            self.range = try container.decodeIfPresent(EitherNode<Int, [LevelRange]>.self, forKey: .range)?.mapRight { $0.map { $0.range } } ?? .left(0)
            self.interval = try container.decodeIfPresent(Int.self, forKey: .interval) ?? 0
            self.target = try container.decodeIfPresent(BattleCheckTarget.self, forKey: .target) ?? .all
            self.flag = try container.decodeIfPresent([SkillUnitFlag : Bool].self, forKey: .flag)?.unorderedKeys ?? []
        }
    }
}

extension Skill: Comparable {
    public static func < (lhs: Skill, rhs: Skill) -> Bool {
        lhs.id < rhs.id
    }
}
