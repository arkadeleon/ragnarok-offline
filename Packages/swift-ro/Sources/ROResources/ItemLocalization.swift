//
//  ItemLocalization.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/28.
//

import Foundation
import Lua

public actor ItemLocalization {
    public static let shared = ItemLocalization(locale: .current)

    let locale: Locale
    let context = LuaContext()

    var identifiedItemDisplayNameTable: [Int : Data] = [:]
    var identifiedItemDescriptionTable: [Int : Data] = [:]

    var isItemScriptsLoaded = false
    var isIdentifiedItemDisplayNameTableLoaded = false
    var isIdentifiedItemDescriptionTableLoaded = false

    init(locale: Locale) {
        self.locale = locale
    }

    public func localizedName(for itemID: Int) -> String? {
        if let url = Bundle.module.url(forResource: "itemInfo", withExtension: "lub", locale: locale) {
            try? loadItemScriptsIfNeeded(url)

            guard let result = try? context.call("identifiedItemDisplayName", with: [itemID]) as? String else {
                return nil
            }

            let encoding = locale.language.preferredEncoding
            let itemDisplayName = result.data(using: .isoLatin1)?.string(using: encoding)
            return itemDisplayName
        } else {
            try? loadIdentifiedItemDisplayNameTableIfNeeded()

            let encoding = locale.language.preferredEncoding
            let itemDisplayName = identifiedItemDisplayNameTable[itemID]?.string(using: encoding)
            return itemDisplayName
        }
    }

    public func localizedDescription(for itemID: Int) -> String? {
        if let url = Bundle.module.url(forResource: "itemInfo", withExtension: "lub", locale: locale) {
            try? loadItemScriptsIfNeeded(url)

            guard let result = try? context.call("identifiedItemDescription", with: [itemID]) as? [String] else {
                return nil
            }

            let encoding = locale.language.preferredEncoding
            let itemDescription = result.joined(separator: "\n").data(using: .isoLatin1)?.string(using: encoding)
            return itemDescription
        } else {
            try? loadIdentifiedItemDescriptionTableIfNeeded()

            let encoding = locale.language.preferredEncoding
            let itemDescription = identifiedItemDescriptionTable[itemID]?.string(using: encoding)
            return itemDescription
        }
    }

    private func loadItemScriptsIfNeeded(_ url: URL) throws {
        guard !isItemScriptsLoaded else {
            return
        }

        let iteminfo = try Data(contentsOf: url)
        try context.load(iteminfo)

        try context.parse("""
        function unidentifiedItemDisplayName(itemID)
            return tbl[itemID]["unidentifiedDisplayName"]
        end
        function unidentifiedItemDescription(itemID)
            return tbl[itemID]["unidentifiedDescriptionName"]
        end
        function identifiedItemDisplayName(itemID)
            return tbl[itemID]["identifiedDisplayName"]
        end
        function identifiedItemDescription(itemID)
            return tbl[itemID]["identifiedDescriptionName"]
        end
        """)

        isItemScriptsLoaded = true
    }

    private func loadIdentifiedItemDisplayNameTableIfNeeded() throws {
        guard !isIdentifiedItemDisplayNameTableLoaded else {
            return
        }

        guard let url = Bundle.module.url(forResource: "idnum2itemdisplaynametable", withExtension: "txt", locale: locale) else {
            return
        }

        let data = try Data(contentsOf: url)

        guard let string = String(data: data, encoding: .isoLatin1) else {
            return
        }

        let lines = string.split(separator: "\r\n")
        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                continue
            }

            let columns = line.split(separator: "#")
            if columns.count >= 2 {
                let itemID = Int(columns[0])
                let itemDisplayName = String(columns[1])
                if let itemID {
                    identifiedItemDisplayNameTable[itemID] = itemDisplayName.data(using: .isoLatin1)
                }
            }
        }

        isIdentifiedItemDisplayNameTableLoaded = true
    }

    private func loadIdentifiedItemDescriptionTableIfNeeded() throws {
        guard !isIdentifiedItemDescriptionTableLoaded else {
            return
        }

        guard let url = Bundle.module.url(forResource: "idnum2itemdesctable", withExtension: "txt", locale: locale) else {
            return
        }

        let data = try Data(contentsOf: url)

        guard let string = String(data: data, encoding: .isoLatin1) else {
            return
        }

        let lines = string.split(separator: "\r\n#\r\n")
        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                continue
            }

            let columns = line.split(separator: "#")
            if columns.count >= 2 {
                let itemID = Int(columns[0])
                let itemDescription = String(columns[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                if let itemID {
                    identifiedItemDescriptionTable[itemID] = itemDescription.data(using: .isoLatin1)
                }
            }
        }

        isIdentifiedItemDescriptionTableLoaded = true
    }
}
