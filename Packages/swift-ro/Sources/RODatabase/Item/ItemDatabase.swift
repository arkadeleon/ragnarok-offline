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

    private lazy var _usableItems: [Item] = {
        do {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/item_db_usable.yml")
            let data = try Data(contentsOf: url)
            let usableItems = try decoder.decode(ListNode<Item>.self, from: data).body

            return usableItems
        } catch {
            logger.warning("\(error.localizedDescription)")
            return []
        }
    }()

    private lazy var _equipItems: [Item] = {
        do {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/item_db_equip.yml")
            let data = try Data(contentsOf: url)
            let equipItems = try decoder.decode(ListNode<Item>.self, from: data).body

            return equipItems
        } catch {
            logger.warning("\(error.localizedDescription)")
            return []
        }
    }()

    private lazy var _etcItems: [Item] = {
        do {
            let decoder = YAMLDecoder()

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/\(mode.path)/item_db_etc.yml")
            let data = try Data(contentsOf: url)
            let etcItems = try decoder.decode(ListNode<Item>.self, from: data).body

            return etcItems
        } catch {
            logger.warning("\(error.localizedDescription)")
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

    private init(mode: DatabaseMode) {
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
