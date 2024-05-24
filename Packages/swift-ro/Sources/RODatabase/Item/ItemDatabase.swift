//
//  ItemDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaCommon
import rAthenaResource
import rAthenaRyml

public actor ItemDatabase {
    public static let prerenewal = ItemDatabase(mode: .prerenewal)
    public static let renewal = ItemDatabase(mode: .renewal)

    public static func database(for mode: ServerMode) -> ItemDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private var cachedUsableItems: [Item] = []
    private var cachedEquipItems: [Item] = []
    private var cachedEtcItems: [Item] = []
    private var cachedItems: [Item] = []
    private var cachedItemsByIDs: [Int : Item] = [:]
    private var cachedItemsByAegisNames: [String : Item] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func usableItems() throws -> [Item] {
        if cachedUsableItems.isEmpty {
            let decoder = YAMLDecoder()

            let usableItemURL = ResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("item_db_usable.yml")
            let usableItemData = try Data(contentsOf: usableItemURL)
            cachedUsableItems = try decoder.decode(ListNode<Item>.self, from: usableItemData).body
        }

        return cachedUsableItems
    }

    public func equipItems() throws -> [Item] {
        if cachedEquipItems.isEmpty {
            let decoder = YAMLDecoder()

            let equipItemURL = ResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
                .appendingPathComponent("item_db_equip.yml")
            let equipItemData = try Data(contentsOf: equipItemURL)
            cachedEquipItems = try decoder.decode(ListNode<Item>.self, from: equipItemData).body
        }

        return cachedEquipItems
    }

    public func etcItems() throws -> [Item] {
        if cachedEtcItems.isEmpty {
            let decoder = YAMLDecoder()

            let etcItemURL = ResourceBundle.shared.dbURL
                .appendingPathComponent(mode.dbPath)
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
        if cachedItemsByIDs.isEmpty {
            let items = try items()
            cachedItemsByIDs = Dictionary(items.map({ ($0.id, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let item = cachedItemsByIDs[id]
        return item
    }

    public func item(forAegisName aegisName: String) throws -> Item? {
        if cachedItemsByAegisNames.isEmpty {
            let items = try items()
            cachedItemsByAegisNames = Dictionary(items.map({ ($0.aegisName, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let item = cachedItemsByAegisNames[aegisName]
        return item
    }
}
