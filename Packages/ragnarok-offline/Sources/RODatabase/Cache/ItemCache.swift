//
//  ItemCache.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaCommon
import rAthenaResource
import rAthenaRyml

actor ItemCache {
    let mode: ServerMode

    private(set) var usableItems: [Item] = []
    private(set) var equipItems: [Item] = []
    private(set) var etcItems: [Item] = []

    private(set) var items: [Item] = []
    private(set) var itemsByIDs: [Int : Item] = [:]
    private(set) var itemsByAegisNames: [String : Item] = [:]

    init(mode: ServerMode) {
        self.mode = mode
    }

    func restoreUsableItems() throws {
        guard usableItems.isEmpty else {
            return
        }

        let decoder = YAMLDecoder()

        let usableItemURL = ResourceBundle.shared.dbURL
            .appendingPathComponent(mode.dbPath)
            .appendingPathComponent("item_db_usable.yml")
        let usableItemData = try Data(contentsOf: usableItemURL)
        usableItems = try decoder.decode(ListNode<Item>.self, from: usableItemData).body
    }

    func restoreEquipItems() throws {
        guard equipItems.isEmpty else {
            return
        }

        let decoder = YAMLDecoder()

        let equipItemURL = ResourceBundle.shared.dbURL
            .appendingPathComponent(mode.dbPath)
            .appendingPathComponent("item_db_equip.yml")
        let equipItemData = try Data(contentsOf: equipItemURL)
        equipItems = try decoder.decode(ListNode<Item>.self, from: equipItemData).body
    }

    func restoreEtcItems() throws {
        guard etcItems.isEmpty else {
            return
        }

        let decoder = YAMLDecoder()

        let etcItemURL = ResourceBundle.shared.dbURL
            .appendingPathComponent(mode.dbPath)
            .appendingPathComponent("item_db_etc.yml")
        let etcItemData = try Data(contentsOf: etcItemURL)
        etcItems = try decoder.decode(ListNode<Item>.self, from: etcItemData).body
    }

    func restoreItems() throws {
        guard items.isEmpty else {
            return
        }

        try restoreUsableItems()
        try restoreEquipItems()
        try restoreEtcItems()

        items = usableItems + equipItems + etcItems

        itemsByIDs = Dictionary(items.map({ ($0.id, $0) }), uniquingKeysWith: { (first, _) in first })
        itemsByAegisNames = Dictionary(items.map({ ($0.aegisName, $0) }), uniquingKeysWith: { (first, _) in first })
    }
}
