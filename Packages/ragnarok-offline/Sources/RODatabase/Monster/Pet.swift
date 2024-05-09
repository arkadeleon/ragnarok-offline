//
//  Pet.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

public struct Pet: Decodable {

    /// Monster that can be used as pet.
    public var monster: String

    /// Pet Tame Item.
    public var tameItem: String?

    /// Pet Egg Item.
    public var eggItem: String

    /// Pet Accessory Item. (Default: 0)
    public var equipItem: String?

    /// Pet Food Item. (Default: 0)
    public var foodItem: String?

    /// The amount of hunger is decreased every [HungryDelay] seconds.
    public var fullness: Int

    /// The amount of time in seconds it takes for hunger to decrease after feeding. (Default: 60)
    public var hungryDelay: Int

    /// The amount of hunger that is increased every time the pet is fed (Default: 20)
    public var hungerIncrease: Int

    /// Amount of Intimacy the pet starts with. (Default: 250)
    public var intimacyStart: Int

    /// Amount of Intimacy that is increased when fed. (Default: 50)
    public var intimacyFed: Int

    /// Amount of Intimacy that is increased when over-fed. (Default: -100)
    public var intimacyOverfed: Int

    /// Amount of Intimacy that is increased when the pet is hungry. (Default: -5)
    public var intimacyHungry: Int

    /// Amount of Intimacy that is increased when the pet owner dies. (Default: -20)
    public var intimacyOwnerDie: Int

    /// Capture success rate. (10000 = 100%)
    public var captureRate: Int

    /// If a pet has a Special Performance. (Default: true)
    public var specialPerformance: Bool

    /// Rate of which the pet will attack [requires at least pet_support_min_friendly intimacy]. (10000 = 100%)
    public var attackRate: Int

    /// Rate of which the pet will retaliate when master is being attacked [requires at least pet_support_min_friendly intimacy]. (10000 = 100%)
    public var retaliateRate: Int

    /// Rate of which the pet will change its attack target. (10000 = 100%)
    public var changeTargetRate: Int

    /// Allows turning automatic pet feeding on. (Default: false)
    public var allowAutoFeed: Bool

    /// Bonus script to execute when the pet is alive. (Default: null)
    public var script: String?

    /// Bonus script to execute when pet_status_support is enabled. (Default: null)
    public var supportScript: String?

    /// Pet evolution settings. (Optional) (Default: null)
    public var evolution: [Evolution]?

    enum CodingKeys: String, CodingKey {
        case monster = "Mob"
        case tameItem = "TameItem"
        case eggItem = "EggItem"
        case equipItem = "EquipItem"
        case foodItem = "FoodItem"
        case fullness = "Fullness"
        case hungryDelay = "HungryDelay"
        case hungerIncrease = "HungerIncrease"
        case intimacyStart = "IntimacyStart"
        case intimacyFed = "IntimacyFed"
        case intimacyOverfed = "IntimacyOverfed"
        case intimacyHungry = "IntimacyHungry"
        case intimacyOwnerDie = "IntimacyOwnerDie"
        case captureRate = "CaptureRate"
        case specialPerformance = "SpecialPerformance"
        case attackRate = "AttackRate"
        case retaliateRate = "RetaliateRate"
        case changeTargetRate = "ChangeTargetRate"
        case allowAutoFeed = "AllowAutoFeed"
        case script = "Script"
        case supportScript = "SupportScript"
        case evolution = "Evolution"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.monster = try container.decode(String.self, forKey: .monster)
        self.tameItem = try container.decodeIfPresent(String.self, forKey: .tameItem)
        self.eggItem = try container.decode(String.self, forKey: .eggItem)
        self.equipItem = try container.decodeIfPresent(String.self, forKey: .equipItem)
        self.foodItem = try container.decodeIfPresent(String.self, forKey: .foodItem)
        self.fullness = try container.decode(Int.self, forKey: .fullness)
        self.hungryDelay = try container.decodeIfPresent(Int.self, forKey: .hungryDelay) ?? 60
        self.hungerIncrease = try container.decodeIfPresent(Int.self, forKey: .hungerIncrease) ?? 20
        self.intimacyStart = try container.decodeIfPresent(Int.self, forKey: .intimacyStart) ?? 250
        self.intimacyFed = try container.decodeIfPresent(Int.self, forKey: .intimacyFed) ?? 50
        self.intimacyOverfed = try container.decodeIfPresent(Int.self, forKey: .intimacyOverfed) ?? -100
        self.intimacyHungry = try container.decodeIfPresent(Int.self, forKey: .intimacyHungry) ?? -5
        self.intimacyOwnerDie = try container.decodeIfPresent(Int.self, forKey: .intimacyOwnerDie) ?? -20
        self.captureRate = try container.decode(Int.self, forKey: .captureRate)
        self.specialPerformance = try container.decodeIfPresent(Bool.self, forKey: .specialPerformance) ?? true
        self.attackRate = try container.decodeIfPresent(Int.self, forKey: .attackRate) ?? 10001
        self.retaliateRate = try container.decodeIfPresent(Int.self, forKey: .retaliateRate) ?? 10001
        self.changeTargetRate = try container.decodeIfPresent(Int.self, forKey: .changeTargetRate) ?? 10001
        self.allowAutoFeed = try container.decodeIfPresent(Bool.self, forKey: .allowAutoFeed) ?? false
        self.script = try container.decodeIfPresent(String.self, forKey: .script)
        self.supportScript = try container.decodeIfPresent(String.self, forKey: .supportScript)
        self.evolution = try container.decodeIfPresent([Evolution].self, forKey: .evolution)
    }
}

extension Pet {

    /// Pet evolution settings.
    public struct Evolution: Decodable {

        /// Mob this pet can evolve to.
        public var target: String

        /// Item requirements for evolving this pet.
        public var itemRequirements: [ItemRequirement]

        enum CodingKeys: String, CodingKey {
            case target = "Target"
            case itemRequirements = "ItemRequirements"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.target = try container.decode(String.self, forKey: .target)
            self.itemRequirements = try container.decode([ItemRequirement].self, forKey: .itemRequirements)
        }
    }
}

extension Pet.Evolution {

    /// Item requirement.
    public struct ItemRequirement: Decodable {

        /// Item.
        public var item: String

        /// Amount.
        public var amount: Int

        enum CodingKeys: String, CodingKey {
            case item = "Item"
            case amount = "Amount"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.item = try container.decode(String.self, forKey: .item)
            self.amount = try container.decode(Int.self, forKey: .amount)
        }
    }
}
