//
//  MonsterSkill.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/19.
//

/// A skill that a monster casts.
///
/// `MobID,Dummy value (info only),State,SkillID,SkillLv,Rate,CastTime,Delay,Cancelable,Target,Condition type,Condition value,val1,val2,val3,val4,val5,Emotion,Chat`
public struct MonsterSkill: Sendable {

    public enum State: String, Sendable {

        /// All states except dead.
        case any

        /// In standby.
        case idle

        /// In movement.
        case walk

        /// On killed.
        case dead

        case loot

        case attack

        /// Like attack, except player has not attacked mob yet.
        case angry

        /// Following target, after being attacked.
        case chase

        /// Following target, without being attacked.
        case follow

        /// attack + angry + chase + follow.
        case anyTarget = "anytarget"
    }

    public enum Target: String, Sendable {

        /// Current target.
        case target

        case `self`

        case friend

        case master

        /// Any enemy within skill's range.
        case randomTarget = "randomtarget"

        /// 3x3 area around self.
        case around1

        /// 5x5 area around self.
        case around2

        /// 7x7 area around self.
        case around3

        /// 9x9 area around self.
        case around4

        /// 3x3 area around target.
        case around5

        /// 5x5 area around target.
        case around6

        /// 7x7 area around target.
        case around7

        /// 9x9 area around target.
        case around8

        /// Same as around4.
        case around
    }

    public enum Condition: String, Sendable {

        /// Unconditional (no condition value).
        case always

        /// When mob spawns/respawns (no condition value).
        case onSpawn = "onspawn"

        /// When mob's HP drops to the specified %.
        case myHPLessThanMaxRate = "myhpltmaxrate"

        /// When mob's HP is in a certain % range (condition value = lower bound, val1 = upper bound).
        case myHPInRate = "myhpinrate"

        /// If mob has the specified abnormality in status.
        case myStatusOn = "mystatuson"

        /// If mob has ended the specified abnormality in status.
        case myStatusOff = "mystatusoff"

        /// When mob's friend's HP drops to the specified %.
        case friendHPLessThanMaxRate = "friendhpltmaxrate"

        /// When mob's friend's HP is in a certain % range (condition value = lower bound, val1 = upper bound).
        case friendHPInRate = "friendhpinrate"

        /// If friend has the specified abnormality in status.
        case friendStatusOn = "friendstatuson"

        /// If friend has ended the specified abnormality in status.
        case friendStatusOff = "friendstatusoff"

        /// When attack PCs become greater than specified number.
        case attackPCGreaterThan = "attackpcgt"

        /// When attack PCs become greater than or equal to the specified number.
        case attackPCGreaterThanOrEqualTo = "attackpcge"

        /// When number of slaves is less than the original specified number.
        case slaveLessThan = "slavelt"

        /// When number of slaves is less than or equal to the original specified number.
        case slaveLessThanOrEqualTo = "slavele"

        /// When close range melee attacked (no condition value).
        case closedAttacked = "closedattacked"

        /// When long range attacked, ex. bows, guns, ranged skills (no condition value).
        case longRangeAttacked = "longrangeattacked"

        /// When the specified skill is used on the mob.
        case skillUsed = "skillused"

        /// After mob casts the specified skill.
        case afterSkill = "afterskill"

        /// When a target is in cast range (no condition value).
        case castTargeted = "casttargeted"

        /// When mob is rude attacked (no condition value).
        case rudeAttacked = "rudeattacked"

        case masterHPLessThanMaxRate = "masterhpltmaxrate"

        case masterAttacked = "masterattacked"

        /// When mob has a special AI, is not trickcasting, and is wounded (no condition value).
        case alchemist

        /// When monsters in range become greater than specified number.
        case mobNearbyGreaterThan = "mobnearbygt"

        /// When mob is hit by ground targeted skill (no condition value).
        case groundAttacked = "groundattacked"

        /// When single attack deals greater damage than specified number.
        case damagedGreaterThan = "damagedgt"

        /// Used once mob started moving through NPC_RANDOMMOVE until disabled (no condition value).
        case trickCasting = "trickcasting"
    }

    /// If negative, the skill is treated as 'global':
    /// -1: added for all boss types.
    /// -2: added for all normal types.
    /// -3: added for all mobs.
    public var monsterID: Int

    public var state: MonsterSkill.State

    public var skillID: Int

    public var skillLevel: Int

    /// The chance of the skill being casted when the condition is fulfilled (10000 = 100%).
    public var rate: Int

    /// Cast time in milliseconds.
    public var castTime: Int

    /// The time (in milliseconds) before attempting to recast the same skill.
    public var delay: Int

    public var cancelable: Bool

    public var target: MonsterSkill.Target

    public var condition: MonsterSkill.Condition

    /// A number, or a status abnormality for the statuson/statusoff conditions:
    /// anybad (any type of state change) / stone / freeze / stun / sleep /
    /// poison / curse / silence / confusion / blind / hiding / sight (unhidden)
    public var conditionValue: String

    public var val1: Int?

    public var val2: Int?

    public var val3: Int?

    public var val4: Int?

    public var val5: Int?

    public var emotion: Int?

    public var chat: Int?

    init?(_ columns: [String]) {
        guard columns.count == 19,
              let monsterID = Int(columns[0]), monsterID != 0,
              let state = MonsterSkill.State(rawValue: columns[2]),
              let skillID = Int(columns[3]),
              let condition = MonsterSkill.Condition(rawValue: columns[10]) else {
            return nil
        }

        self.monsterID = monsterID
        self.state = state
        self.skillID = skillID
        self.skillLevel = max(Int(columns[4]) ?? 1, 1)
        self.rate = min(Int(columns[5]) ?? 0, 10000)
        self.castTime = Int(columns[6]) ?? 0
        self.delay = Int(columns[7]) ?? 0
        self.cancelable = columns[8] == "yes" || (Int(columns[8]) ?? 0) != 0
        self.target = MonsterSkill.Target(rawValue: columns[9]) ?? .target
        self.condition = condition
        self.conditionValue = columns[11]
        self.val1 = Int(hexadecimalOrDecimal: columns[12])
        self.val2 = Int(hexadecimalOrDecimal: columns[13])
        self.val3 = Int(hexadecimalOrDecimal: columns[14])
        self.val4 = Int(hexadecimalOrDecimal: columns[15])
        self.val5 = Int(hexadecimalOrDecimal: columns[16])
        self.emotion = Int(columns[17])
        self.chat = Int(columns[18])
    }
}

extension Int {
    /// Accepts a decimal string such as `129`, or a hexadecimal string with a `0x` prefix such as `0x81`.
    fileprivate init?(hexadecimalOrDecimal string: String) {
        if string.hasPrefix("0x") || string.hasPrefix("0X") {
            self.init(string.dropFirst(2), radix: 16)
        } else {
            self.init(string)
        }
    }
}
