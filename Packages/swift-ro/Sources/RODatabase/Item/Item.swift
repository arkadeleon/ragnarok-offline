//
//  Item.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/18.
//

public struct Item: Decodable, Equatable, Hashable, Identifiable {

    /// Item ID.
    public var id: Int

    /// Server name to reference the item in scripts and lookups, should use no spaces.
    public var aegisName: String

    /// Name in English for displaying as output.
    public var name: String

    /// Item type. (Default: Etc)
    public var type: ItemType

    /// Weapon, Ammo or Card type. (Default: 0)
    public var subType: ItemSubType

    /// Buying price. When not specified, becomes double the sell price. (Default: 0)
    public var buy: Int

    /// Selling price. When not specified, becomes half the buy price. (Default: 0)
    public var sell: Int

    /// Item weight. Each 10 is 1 weight. (Default: 0)
    public var weight: Int

    /// Weapon's attack. (Default: 0)
    public var attack: Int

    /// Weapon's magic attack. (Default: 0)
    public var magicAttack: Int

    /// Armor's defense. (Default: 0)
    public var defense: Int

    /// Weapon's attack range. (Default: 0)
    public var range: Int

    /// Available slots in item. (Default: 0)
    public var slots: Int

    /// Jobs that can equip the item. (Map default is 'All: true')
    public var jobs: [ItemJob]

    /// Upper class types that can equip the item. (Map default is 'All: true')
    public var classes: Set<ItemClass>

    /// Gender that can equip the item. (Default: Both)
    public var gender: Gender

    /// Equipment's placement. (Default: None)
    public var locations: [ItemLocation]

    /// Weapon level. (Default: 1 for Weapons)
    public var weaponLevel: Int

    /// Armor level. (Default: 1 for Armors)
    public var armorLevel: Int

    /// Minimum required level to equip. (Default: 0)
    public var equipLevelMin: Int

    /// Maximum level that can equip. (Default: 0)
    public var equipLevelMax: Int

    /// If the item can be refined. (Default: false)
    public var refineable: Bool

    /// If the item can be graded. (Default: false)
    public var gradable: Bool

    /// View sprite of an item. (Default: 0)
    public var view: Int

    /// Another item's AegisName that will be sent to the client instead of this item's AegisName. (Default: null)
    public var aliasName: String?

    /// Item flags. (Default: null)
    public var flags: Flags?

    /// Item use delay. (Default: null)
    public var delay: Delay?

    /// Item stack amount. (Default: null)
    public var stack: Stack?

    /// Conditions when the item is unusable. (Default: null)
    public var noUse: NoUse?

    /// Trade restrictions. (Default: null)
    public var trade: Trade?

    /// Script to execute when the item is used/equipped. (Default: null)
    public var script: String?

    /// Script to execute when the item is equipped. (Default: null)
    public var equipScript: String?

    /// Script to execute when the item is unequipped or when a rental item expires. (Default: null)
    public var unEquipScript: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case aegisName = "AegisName"
        case name = "Name"
        case type = "Type"
        case subType = "SubType"
        case buy = "Buy"
        case sell = "Sell"
        case weight = "Weight"
        case attack = "Attack"
        case magicAttack = "MagicAttack"
        case defense = "Defense"
        case range = "Range"
        case slots = "Slots"
        case jobs = "Jobs"
        case classes = "Classes"
        case gender = "Gender"
        case locations = "Locations"
        case weaponLevel = "WeaponLevel"
        case armorLevel = "ArmorLevel"
        case equipLevelMin = "EquipLevelMin"
        case equipLevelMax = "EquipLevelMax"
        case refineable = "Refineable"
        case gradable = "Gradable"
        case view = "View"
        case aliasName = "AliasName"
        case flags = "Flags"
        case delay = "Delay"
        case stack = "Stack"
        case noUse = "NoUse"
        case trade = "Trade"
        case script = "Script"
        case equipScript = "EquipScript"
        case unEquipScript = "UnEquipScript"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.aegisName = try container.decode(String.self, forKey: .aegisName)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decodeIfPresent(ItemType.self, forKey: .type) ?? .etc

        switch type {
        case .weapon:
            let weaponType = try container.decodeIfPresent(WeaponType.self, forKey: .subType) ?? .fist
            self.subType = .weapon(weaponType)
        case .ammo:
            let ammoType = try container.decodeIfPresent(AmmoType.self, forKey: .subType) ?? .arrow
            self.subType = .ammo(ammoType)
        case .card:
            let cardType = try container.decodeIfPresent(CardType.self, forKey: .subType) ?? .normal
            self.subType = .card(cardType)
        default:
            self.subType = .none
        }

        let buy = try container.decodeIfPresent(Int.self, forKey: .buy)
        let sell = try container.decodeIfPresent(Int.self, forKey: .sell)
        if let buy, sell == nil {
            self.buy = buy
            self.sell = buy / 2
        } else if let sell, buy == nil {
            self.sell = sell
            self.buy = sell * 2
        } else {
            self.buy = buy ?? 0
            self.sell = sell ?? 0
        }

        self.weight = try container.decodeIfPresent(Int.self, forKey: .weight) ?? 0
        self.attack = try container.decodeIfPresent(Int.self, forKey: .attack) ?? 0
        self.magicAttack = try container.decodeIfPresent(Int.self, forKey: .magicAttack) ?? 0
        self.defense = try container.decodeIfPresent(Int.self, forKey: .defense) ?? 0
        self.range = try container.decodeIfPresent(Int.self, forKey: .range) ?? 0
        self.slots = try container.decodeIfPresent(Int.self, forKey: .slots) ?? 0
        self.jobs = try container.decodeIfPresent(PairsNode<ItemJob, Bool>.self, forKey: .jobs)?.keys ?? [.all]
        self.classes = try container.decodeIfPresent([String : Bool].self, forKey: .classes).map(Set<ItemClass>.init) ?? Set(ItemClass.allCases)
        self.gender = try container.decodeIfPresent(Gender.self, forKey: .gender) ?? .both
        self.locations = try container.decodeIfPresent(PairsNode<ItemLocation, Bool>.self, forKey: .locations)?.keys ?? []
        self.weaponLevel = try container.decodeIfPresent(Int.self, forKey: .weaponLevel) ?? 1
        self.armorLevel = try container.decodeIfPresent(Int.self, forKey: .armorLevel) ?? 1
        self.equipLevelMin = try container.decodeIfPresent(Int.self, forKey: .equipLevelMin) ?? 0
        self.equipLevelMax = try container.decodeIfPresent(Int.self, forKey: .equipLevelMax) ?? 0
        self.refineable = try container.decodeIfPresent(Bool.self, forKey: .refineable) ?? false
        self.gradable = try container.decodeIfPresent(Bool.self, forKey: .gradable) ?? false
        self.view = try container.decodeIfPresent(Int.self, forKey: .view) ?? 0
        self.aliasName = try container.decodeIfPresent(String.self, forKey: .aliasName)
        self.flags = try container.decodeIfPresent(Flags.self, forKey: .flags)
        self.delay = try container.decodeIfPresent(Delay.self, forKey: .delay)
        self.stack = try container.decodeIfPresent(Stack.self, forKey: .stack)
        self.noUse = try container.decodeIfPresent(NoUse.self, forKey: .noUse)
        self.trade = try container.decodeIfPresent(Trade.self, forKey: .trade)
        self.script = try container.decodeIfPresent(String.self, forKey: .script)
        self.equipScript = try container.decodeIfPresent(String.self, forKey: .equipScript)
        self.unEquipScript = try container.decodeIfPresent(String.self, forKey: .unEquipScript)
    }
}

extension Item {

    /// Item flags.
    public struct Flags: Decodable, Equatable, Hashable {

        /// If the item is available for Buyingstores. (Default: false)
        public var buyingStore: Bool

        /// If the item is a Dead Branch. (Default: false)
        public var deadBranch: Bool

        /// If the item is part of a container. (Default: false)
        public var container: Bool

        /// If the item is a unique stack. (Default: false)
        public var uniqueId: Bool

        /// If the item is bound to the character upon equipping. (Default: false)
        public var bindOnEquip: Bool

        /// If the item has a special announcement to self on drop. (Default: false)
        public var dropAnnounce: Bool

        /// If the item is consumed on use. (Default: false)
        public var noConsume: Bool

        /// If the item has a special effect on the ground when dropped by a monster. (Default: None)
        public var dropEffect: String?

        enum CodingKeys: String, CodingKey {
            case buyingStore = "BuyingStore"
            case deadBranch = "DeadBranch"
            case container = "Container"
            case uniqueId = "UniqueId"
            case bindOnEquip = "BindOnEquip"
            case dropAnnounce = "DropAnnounce"
            case noConsume = "NoConsume"
            case dropEffect = "DropEffect"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.buyingStore = try container.decodeIfPresent(Bool.self, forKey: .buyingStore) ?? false
            self.deadBranch = try container.decodeIfPresent(Bool.self, forKey: .deadBranch) ?? false
            self.container = try container.decodeIfPresent(Bool.self, forKey: .container) ?? false
            self.uniqueId = try container.decodeIfPresent(Bool.self, forKey: .uniqueId) ?? false
            self.bindOnEquip = try container.decodeIfPresent(Bool.self, forKey: .bindOnEquip) ?? false
            self.dropAnnounce = try container.decodeIfPresent(Bool.self, forKey: .dropAnnounce) ?? false
            self.noConsume = try container.decodeIfPresent(Bool.self, forKey: .noConsume) ?? false
            self.dropEffect = try container.decodeIfPresent(String.self, forKey: .dropEffect)
        }
    }
}

extension Item {

    /// Item use delay.
    public struct Delay: Decodable, Equatable, Hashable {

        /// Duration of delay in seconds.
        public var duration: Int

        /// Status Change used to track delay. (Default: None)
        public var status: String?

        enum CodingKeys: String, CodingKey {
            case duration = "Duration"
            case status = "Status"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.duration = try container.decode(Int.self, forKey: .duration)
            self.status = try container.decodeIfPresent(String.self, forKey: .status)
        }
    }
}

extension Item {

    /// Item stack amount.
    public struct Stack: Decodable, Equatable, Hashable {

        /// Maximum amount that can be stacked.
        public var amount: Int

        /// If the stack is applied to player's inventory. (Default: true)
        public var inventory: Bool

        /// If the stack is applied to the player's cart. (Default: false)
        public var cart: Bool

        /// If the stack is applied to the player's storage. (Default: false)
        public var storage: Bool

        /// If the stack is applied to the player's guild storage. (Default: false)
        public var guildStorage: Bool

        enum CodingKeys: String, CodingKey {
            case amount = "Amount"
            case inventory = "Inventory"
            case cart = "Cart"
            case storage = "Storage"
            case guildStorage = "GuildStorage"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.amount = try container.decode(Int.self, forKey: .amount)
            self.inventory = try container.decodeIfPresent(Bool.self, forKey: .inventory) ?? true
            self.cart = try container.decodeIfPresent(Bool.self, forKey: .cart) ?? false
            self.storage = try container.decodeIfPresent(Bool.self, forKey: .storage) ?? false
            self.guildStorage = try container.decodeIfPresent(Bool.self, forKey: .guildStorage) ?? false
        }
    }
}

extension Item {

    /// Conditions when the item is unusable.
    public struct NoUse: Decodable, Equatable, Hashable {

        /// Group level to override these conditions. (Default: 100)
        public var override: Int

        /// If the item can not be used while sitting. (Default: false)
        public var sitting: Bool

        enum CodingKeys: String, CodingKey {
            case override = "Override"
            case sitting = "Sitting"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.override = try container.decodeIfPresent(Int.self, forKey: .override) ?? 100
            self.sitting = try container.decodeIfPresent(Bool.self, forKey: .sitting) ?? false
        }
    }
}

extension Item {

    /// Trade restrictions.
    public struct Trade: Decodable, Equatable, Hashable {

        /// Group level to override these conditions. (Default: 100)
        public var override: Int

        /// If the item can not be dropped. (Default: false)
        public var noDrop: Bool

        /// If the item can not be traded. (Default: false)
        public var noTrade: Bool

        /// If the item can not be traded to the player's partner. (Default: false)
        public var tradePartner: Bool

        /// If the item can not be sold. (Default: false)
        public var noSell: Bool

        /// If the item can not be put in a cart. (Default: false)
        public var noCart: Bool

        /// If the item can not be put in a storage. (Default: false)
        public var noStorage: Bool

        /// If the item can not be put in a guild storage. (Default: false)
        public var noGuildStorage: Bool

        /// If the item can not be put in a mail. (Default: false)
        public var noMail: Bool

        /// If the item can not be put in an auction. (Default: false)
        public var noAuction: Bool

        enum CodingKeys: String, CodingKey {
            case override = "Override"
            case noDrop = "NoDrop"
            case noTrade = "NoTrade"
            case tradePartner = "TradePartner"
            case noSell = "NoSell"
            case noCart = "NoCart"
            case noStorage = "NoStorage"
            case noGuildStorage = "NoGuildStorage"
            case noMail = "NoMail"
            case noAuction = "NoAuction"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.override = try container.decodeIfPresent(Int.self, forKey: .override) ?? 100
            self.noDrop = try container.decodeIfPresent(Bool.self, forKey: .noDrop) ?? false
            self.noTrade = try container.decodeIfPresent(Bool.self, forKey: .noTrade) ?? false
            self.tradePartner = try container.decodeIfPresent(Bool.self, forKey: .tradePartner) ?? false
            self.noSell = try container.decodeIfPresent(Bool.self, forKey: .noSell) ?? false
            self.noCart = try container.decodeIfPresent(Bool.self, forKey: .noCart) ?? false
            self.noStorage = try container.decodeIfPresent(Bool.self, forKey: .noStorage) ?? false
            self.noGuildStorage = try container.decodeIfPresent(Bool.self, forKey: .noGuildStorage) ?? false
            self.noMail = try container.decodeIfPresent(Bool.self, forKey: .noMail) ?? false
            self.noAuction = try container.decodeIfPresent(Bool.self, forKey: .noAuction) ?? false
        }
    }
}

extension Item: Comparable {
    public static func < (lhs: Item, rhs: Item) -> Bool {
        lhs.id < rhs.id
    }
}
