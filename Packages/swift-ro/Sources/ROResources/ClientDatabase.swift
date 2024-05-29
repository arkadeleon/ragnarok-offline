//
//  ClientDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/30.
//

import Foundation
import Lua

public actor ClientDatabase {
    public static let shared = ClientDatabase()

    let context = LuaContext()

    var isItemScriptsLoaded = false
    var isMonsterScriptsLoaded = false

    // MARK: - Item

    public func identifiedItemResourceName(for itemID: Int) -> String? {
        try? loadItemScriptsIfNeeded()

        guard let result = try? context.call("identifiedItemResourceName", with: [itemID]) as? String else {
            return nil
        }

        let itemResourceName = result.data(using: .isoLatin1)?.string(using: .koreanEUC)
        return itemResourceName
    }

    private func loadItemScriptsIfNeeded() throws {
        guard !isItemScriptsLoaded else {
            return
        }

        let locale = Locale(languageCode: .korean)
        guard let url = Bundle.module.url(forResource: "itemInfo", withExtension: "lub", locale: locale) else {
            return
        }

        let iteminfo = try Data(contentsOf: url)
        try context.load(iteminfo)

        try context.parse("""
        function unidentifiedItemResourceName(itemID)
            return tbl[itemID]["unidentifiedResourceName"]
        end
        function identifiedItemResourceName(itemID)
            return tbl[itemID]["identifiedResourceName"]
        end
        function itemSlotCount(itemID)
            return tbl[itemID]["slotCount"]
        end
        """)

        isItemScriptsLoaded = true
    }

    // MARK: - Monster

    public func monsterResourceName(for monsterID: Int) -> String? {
        try? loadMonsterScriptsIfNeeded()

        let result = try? context.call("monsterResourceName", with: [monsterID]) as? String
        return result
    }

    private func loadMonsterScriptsIfNeeded() throws {
        guard !isMonsterScriptsLoaded else {
            return
        }

        if let url = Bundle.module.url(forResource: "npcidentity", withExtension: "lub") {
            let data = try Data(contentsOf: url)
            try context.load(data)
        }

        if let url = Bundle.module.url(forResource: "jobname", withExtension: "lub") {
            let data = try Data(contentsOf: url)
            try context.load(data)
        }

        try context.parse("""
        function monsterResourceName(monsterID)
            return JobNameTable[monsterID]
        end
        """)

        isMonsterScriptsLoaded = true
    }
}
