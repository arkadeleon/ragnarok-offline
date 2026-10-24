//
//  ItemProduce.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/25.
//

/// An item produce recipe.
///
/// `ID,ProduceItemID,ItemLV,RequireSkill,RequireSkillLv,MaterialID1,MaterialAmount1,......`
public struct ItemProduce: Equatable, Hashable, Sendable {

    public struct Material: Equatable, Hashable, Sendable {

        public var itemID: Int

        /// If MaterialAmount is 0, the player must have that item in their inventory (i.e. guides).
        public var amount: Int
    }

    /// ID is used to identify item order that will be used for overwriting on db/import.
    public var id: Int

    public var productID: Int

    /// Valid item levels are:
    ///
    /// - 1: Level 1 Weapons
    /// - 2: Level 2 Weapons
    /// - 3: Level 3 Weapons
    /// - 11...20: Level 1...10 Dish
    /// - 21: Blacksmith's Stones and Metals
    /// - 22: Alchemist's Potions, Holy Water, Assassin Cross's Deadly Poison
    /// - 23: Elemental Converters
    public var itemLevel: Int

    public var skillID: Int

    public var skillLevel: Int

    public var materials: [ItemProduce.Material]

    init?(_ columns: [String]) {
        guard columns.count >= 5,
              let id = Int(columns[0]),
              let productID = Int(columns[1]), productID != 0,
              let itemLevel = Int(columns[2]),
              let skillID = Int(columns[3]),
              let skillLevel = Int(columns[4]) else {
            return nil
        }

        self.id = id
        self.productID = productID
        self.itemLevel = itemLevel
        self.skillID = skillID
        self.skillLevel = skillLevel
        self.materials = stride(from: 5, to: columns.count - 1, by: 2).compactMap { index in
            guard let itemID = Int(columns[index]), let amount = Int(columns[index + 1]) else {
                return nil
            }
            return ItemProduce.Material(itemID: itemID, amount: amount)
        }
    }
}
