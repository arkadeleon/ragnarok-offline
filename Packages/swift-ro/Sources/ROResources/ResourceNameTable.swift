//
//  ResourceNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/30.
//

import Foundation
@preconcurrency import Lua

final public class ResourceNameTable: Sendable {
    public static let shared = ResourceNameTable()

    let context: LuaContext

    init() {
        context = {
            let context = LuaContext()

            do {
                let locale = Locale(languageCode: .korean)
                if let data = resourceBundle.data(forResource: "itemInfo", withExtension: "lub", locale: locale) {
                    try context.load(data)
                }

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

                if let url = resourceBundle.url(forResource: "npcidentity", withExtension: "lub") {
                    let data = try Data(contentsOf: url)
                    try context.load(data)
                }

                if let url = resourceBundle.url(forResource: "jobname", withExtension: "lub") {
                    let data = try Data(contentsOf: url)
                    try context.load(data)
                }

                try context.parse("""
                function monsterResourceName(monsterID)
                    return JobNameTable[monsterID]
                end
                """)
            } catch {
                print(error)
            }

            return context
        }()
    }

    // MARK: - Item

    public func identifiedItemResourceName(for itemID: Int) -> String? {
        guard let result = try? context.call("identifiedItemResourceName", with: [itemID]) as? String else {
            return nil
        }

        let locale = Locale(languageCode: .korean)
        let encoding = locale.language.preferredEncoding
        let itemResourceName = result.transcoding(from: .isoLatin1, to: encoding)
        return itemResourceName
    }

    // MARK: - Monster

    public func monsterResourceName(for monsterID: Int) -> String? {
        let result = try? context.call("monsterResourceName", with: [monsterID]) as? String
        return result
    }
}