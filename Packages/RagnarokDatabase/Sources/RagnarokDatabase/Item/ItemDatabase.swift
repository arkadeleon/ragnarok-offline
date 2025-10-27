//
//  ItemDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import RapidYAML

public actor ItemDatabase {
    public let baseURL: URL
    public let mode: DatabaseMode

    private lazy var _usableItems: [Item] = {
        metric.beginMeasuring("Load usable item database")

        do {
            let decoder = YAMLDecoder()

            let url = baseURL.appending(path: "db/\(mode.path)/item_db_usable.yml")
            let data = try Data(contentsOf: url)
            let usableItems = try decoder.decode(ListNode<Item>.self, from: data).body

            metric.endMeasuring("Load usable item database")

            return usableItems
        } catch {
            metric.endMeasuring("Load usable item database", error)

            return []
        }
    }()

    private lazy var _equipItems: [Item] = {
        metric.beginMeasuring("Load equip item database")

        do {
            let decoder = YAMLDecoder()

            let url = baseURL.appending(path: "db/\(mode.path)/item_db_equip.yml")
            let data = try Data(contentsOf: url)
            let equipItems = try decoder.decode(ListNode<Item>.self, from: data).body

            metric.endMeasuring("Load equip item database")

            return equipItems
        } catch {
            metric.endMeasuring("Load equip item database", error)

            return []
        }
    }()

    private lazy var _etcItems: [Item] = {
        metric.beginMeasuring("Load etc item database")

        do {
            let decoder = YAMLDecoder()

            let url = baseURL.appending(path: "db/\(mode.path)/item_db_etc.yml")
            let data = try Data(contentsOf: url)
            let etcItems = try decoder.decode(ListNode<Item>.self, from: data).body

            metric.endMeasuring("Load etc item database")

            return etcItems
        } catch {
            metric.endMeasuring("Load etc item database", error)

            return []
        }
    }()

    private lazy var _items: [Item] = {
        _usableItems + _equipItems + _etcItems
    }()

    private lazy var _itemsByID: [Int : Item] = {
        Dictionary(
            _items.map({ ($0.id, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    private lazy var _itemsByAegisName: [String : Item] = {
        Dictionary(
            _items.map({ ($0.aegisName, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func usableItems() -> [Item] {
        _usableItems
    }

    public func equipItems() -> [Item] {
        _equipItems
    }

    public func etcItems() -> [Item] {
        _etcItems
    }

    public func items() -> [Item] {
        _items
    }

    public func item(forID id: Int) -> Item? {
        _itemsByID[id]
    }

    public func item(forAegisName aegisName: String) -> Item? {
        _itemsByAegisName[aegisName]
    }
}
