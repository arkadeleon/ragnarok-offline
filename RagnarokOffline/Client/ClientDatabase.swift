//
//  ClientDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/30.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation
import Lua

class ClientDatabase {
    static let shared = ClientDatabase()

    private let context = LuaContext()
    private let decompiler = LuaDecompiler()

    private var isItemScriptsLoaded = false
    private var isSkillScriptsLoaded = false

    func itemDisplayName(_ itemID: Int) -> String? {
        try? loadItemScriptsIfNeeded()

        guard let result = try? context.call("itemDisplayName", with: [itemID]) as? String else {
            return nil
        }

        guard let data = result.data(using: .isoLatin1) else {
            return nil
        }

        var convertedString: NSString? = nil
        NSString.stringEncoding(for: data, convertedString: &convertedString, usedLossyConversion: nil)

        return convertedString as String?
    }

    func itemResourceName(_ itemID: Int) -> String? {
        try? loadItemScriptsIfNeeded()

        guard let result = try? context.call("itemResourceName", with: [itemID]) as? String else {
            return nil
        }

        guard let data = result.data(using: .isoLatin1) else {
            return nil
        }

        let string = String(data: data, encoding: .koreanEUC)
        return string
    }

    func itemDescription(_ itemID: Int) -> String? {
        try? loadItemScriptsIfNeeded()

        guard let result = try? context.call("itemDescription", with: [itemID]) as? [String] else {
            return nil
        }

        guard let data = result.joined(separator: "\n").data(using: .isoLatin1) else {
            return nil
        }

        var convertedString: NSString? = nil
        NSString.stringEncoding(for: data, convertedString: &convertedString, usedLossyConversion: nil)

        return convertedString as String?
    }

    func skillDescription(_ skillID: Int) -> String? {
        try? loadSkillScriptsIfNeeded()

        guard let result = try? context.call("skillDescription", with: [skillID]) as? [String] else {
            return nil
        }

        guard let data = result.joined(separator: "\n").data(using: .isoLatin1) else {
            return nil
        }

        var convertedString: NSString? = nil
        NSString.stringEncoding(for: data, convertedString: &convertedString, usedLossyConversion: nil)

        return convertedString as String?
    }

    private func loadItemScriptsIfNeeded() throws {
        guard !isItemScriptsLoaded else {
            return
        }

        let iteminfoURL = ClientBundle.shared.url.appendingPathComponent("System/iteminfo.lua")
        if let iteminfo = try? String(contentsOf: iteminfoURL, encoding: .ascii) {
            try context.parse(iteminfo)
        }

        try context.parse("""
        function itemDisplayName(itemID)
            return tbl[itemID]["identifiedDisplayName"]
        end
        function itemResourceName(itemID)
            return tbl[itemID]["identifiedResourceName"]
        end
        function itemDescription(itemID)
            return tbl[itemID]["identifiedDescriptionName"]
        end
        """)

        isItemScriptsLoaded = true
    }

    private func loadSkillScriptsIfNeeded() throws {
        guard !isSkillScriptsLoaded else {
            return
        }

        try loadScript([
            GRF.Path(string: "data\\lua files\\skillinfoz\\skillid.lub"),
            GRF.Path(string: "data\\luafiles514\\lua files\\skillinfoz\\skillid.lub"),
        ])

        try loadScript([
            GRF.Path(string: "data\\lua files\\skillinfoz\\skilldescript.lub"),
            GRF.Path(string: "data\\luafiles514\\lua files\\skillinfoz\\skilldescript.lub"),
        ])

        try context.parse("""
        function skillDescription(skillID)
            return SKILL_DESCRIPT[skillID]
        end
        """)

        isSkillScriptsLoaded = true
    }

    private func loadScript(_ paths: [GRF.Path]) throws {
        var data: Data?
        for path in paths {
            data = try? ClientBundle.shared.grf.contentsOfEntry(at: path)
            if data != nil {
                break
            }
        }

        guard let data else {
            return
        }

        guard let decompiledData = decompiler.decompileData(data) else {
            return
        }

        /// Drop first "function(...)", drop last "end"
        guard let script = String(data: decompiledData, encoding: .ascii)?
            .dropFirst(13)
            .dropLast(4) else {
            return
        }

        try context.parse(String(script))
    }
}
