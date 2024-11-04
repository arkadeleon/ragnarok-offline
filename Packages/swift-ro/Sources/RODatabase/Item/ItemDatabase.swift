//
//  ItemDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaResources

public actor ItemDatabase {
    public static let prerenewal = ItemDatabase(mode: .prerenewal)
    public static let renewal = ItemDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> ItemDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private var cachedUsableItems: [Item] = []
    private var cachedEquipItems: [Item] = []
    private var cachedEtcItems: [Item] = []
    private var cachedItems: [Item] = []
    private var cachedItemsByID: [Int : Item] = [:]
    private var cachedItemsByAegisName: [String : Item] = [:]

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func usableItems() throws -> [Item] {
        if cachedUsableItems.isEmpty {
            let decoder = YAMLDecoder()

            let usableItemURL = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.path)
                .appendingPathComponent("item_db_usable.yml")
            let usableItemData = try Data(contentsOf: usableItemURL)
            cachedUsableItems = try decoder.decode(ListNode<Item>.self, from: usableItemData).body
        }

        return cachedUsableItems
    }

    public func equipItems() throws -> [Item] {
        if cachedEquipItems.isEmpty {
            let decoder = YAMLDecoder()

            let equipItemURL = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.path)
                .appendingPathComponent("item_db_equip.yml")
            let equipItemData = try Data(contentsOf: equipItemURL)
            cachedEquipItems = try decoder.decode(ListNode<Item>.self, from: equipItemData).body
        }

        return cachedEquipItems
    }

    public func etcItems() throws -> [Item] {
        if cachedEtcItems.isEmpty {
            let decoder = YAMLDecoder()

            let etcItemURL = ServerResourceManager.default.dbURL
                .appendingPathComponent(mode.path)
                .appendingPathComponent("item_db_etc.yml")
            let etcItemData = try Data(contentsOf: etcItemURL)
            cachedEtcItems = try decoder.decode(ListNode<Item>.self, from: etcItemData).body
        }

        return cachedEtcItems
    }

    public func items() throws -> [Item] {
        if cachedItems.isEmpty {
            let usableItems = try usableItems()
            let equipItems = try equipItems()
            let etcItems = try etcItems()

            cachedItems = usableItems + equipItems + etcItems
        }

        return cachedItems
    }

    public func item(forID id: Int) throws -> Item? {
        if cachedItemsByID.isEmpty {
            let items = try items()
            cachedItemsByID = Dictionary(items.map({ ($0.id, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let item = cachedItemsByID[id]
        return item
    }

    public func item(forAegisName aegisName: String) throws -> Item? {
        if cachedItemsByAegisName.isEmpty {
            let items = try items()
            cachedItemsByAegisName = Dictionary(items.map({ ($0.aegisName, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let item = cachedItemsByAegisName[aegisName]
        return item
    }
}
