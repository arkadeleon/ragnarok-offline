//
//  ItemGroup.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/23.
//

import RagnarokConstants

public struct ItemGroup: Decodable, Equatable, Hashable, Sendable {

    /// Group name of the item.
    public var group: String

    /// SubGroups of the item group.
    public var subGroups: [ItemGroup.SubGroup]

    enum CodingKeys: String, CodingKey {
        case group = "Group"
        case subGroups = "SubGroups"
    }
}

extension ItemGroup {

    /// SubGroup of the item group.
    public struct SubGroup: Decodable, Equatable, Hashable, Sendable {

        /// Item in the list of the SubGroup.
        public struct ListItem: Decodable, Equatable, Hashable, Sendable {

            /// Unique number that can be used to add the same Item with different data in the list.
            public var index: Int

            /// AegisName of item that will be obtained from this item group.
            public var item: String

            /// Probability to get the item. (Default: 0)
            public var rate: Int

            /// Amount of item that will be obtained. (Default: 1)
            public var amount: Int

            /// Makes the item a rental item which will expire within the given amount in minutes. Not intended for use with stackable items. (Default: 0)
            public var duration: Int

            /// If player obtains this item it will be broadcasted to the server. (Default: false)
            public var announced: Bool

            /// Makes the given item(s) have a Unique ID. (Default: UniqueId from item_db)
            public var uniqueId: Bool?

            /// Whether stackable items are given stacked or not. (Default: true)
            public var stacked: Bool

            /// Inscribes the item with the obtainer's name. (Default: false)
            public var named: Bool

            /// Binds the obtained item. (Default: None)
            public var bound: ItemBound

            /// Applies random options of this group to all equipable items. (Default: None)
            public var randomOptionGroup: String?

            /// Applies at least this refine level to all equipable items. (Default: 0)
            public var refineMinimum: Int

            /// Applies at most this refine level to all equipable items. (Default: 0)
            public var refineMaximum: Int

            /// Applies at least this level of grade to all equipable items. (Default: None)
            public var gradeMinimum: EnchantGrade

            /// Applies at most this level of grade to all equipable items. (Default: None)
            public var gradeMaximum: EnchantGrade

            /// Whether the current datas should be removed. (Optional)
            public var clear: Bool?

            enum CodingKeys: String, CodingKey {
                case index = "Index"
                case item = "Item"
                case rate = "Rate"
                case amount = "Amount"
                case duration = "Duration"
                case announced = "Announced"
                case uniqueId = "UniqueId"
                case stacked = "Stacked"
                case named = "Named"
                case bound = "Bound"
                case randomOptionGroup = "RandomOptionGroup"
                case refineMinimum = "RefineMinimum"
                case refineMaximum = "RefineMaximum"
                case gradeMinimum = "GradeMinimum"
                case gradeMaximum = "GradeMaximum"
                case clear = "Clear"
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.index = try container.decode(Int.self, forKey: .index)
                self.item = try container.decode(String.self, forKey: .item)
                self.rate = try container.decodeIfPresent(Int.self, forKey: .rate) ?? 0
                self.amount = try container.decodeIfPresent(Int.self, forKey: .amount) ?? 1
                self.duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0
                self.announced = try container.decodeIfPresent(Bool.self, forKey: .announced) ?? false
                self.uniqueId = try container.decodeIfPresent(Bool.self, forKey: .uniqueId)
                self.stacked = try container.decodeIfPresent(Bool.self, forKey: .stacked) ?? true
                self.named = try container.decodeIfPresent(Bool.self, forKey: .named) ?? false
                self.bound = try container.decodeIfPresent(ItemBound.self, forKey: .bound) ?? .none
                self.randomOptionGroup = try container.decodeIfPresent(String.self, forKey: .randomOptionGroup)
                self.refineMinimum = try container.decodeIfPresent(Int.self, forKey: .refineMinimum) ?? 0
                self.refineMaximum = try container.decodeIfPresent(Int.self, forKey: .refineMaximum) ?? 0
                self.gradeMinimum = try container.decodeIfPresent(EnchantGrade.self, forKey: .gradeMinimum) ?? .none
                self.gradeMaximum = try container.decodeIfPresent(EnchantGrade.self, forKey: .gradeMaximum) ?? .none
                self.clear = try container.decodeIfPresent(Bool.self, forKey: .clear)
            }
        }

        /// SubGroup number associated with the list of item. See doc/item_group.txt for more information.
        public var subGroup: Int

        /// Type of algorithm associated with SubGroup. (Default: SharedPool)
        public var algorithm: ItemGroupAlgorithm

        /// List of item(s) for the SubGroup.
        public var list: [ItemGroup.SubGroup.ListItem]

        /// Remove the given SubGroup. (Optional)
        public var clear: Bool?

        enum CodingKeys: String, CodingKey {
            case subGroup = "SubGroup"
            case algorithm = "Algorithm"
            case list = "List"
            case clear = "Clear"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.subGroup = try container.decode(Int.self, forKey: .subGroup)
            self.algorithm = try container.decodeIfPresent(ItemGroupAlgorithm.self, forKey: .algorithm) ?? .sharedpool
            self.list = try container.decode([ItemGroup.SubGroup.ListItem].self, forKey: .list)
            self.clear = try container.decodeIfPresent(Bool.self, forKey: .clear)
        }
    }
}
