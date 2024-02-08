//
//  ClientScriptManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/30.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation
import Lua

class ClientScriptManager {
    static let shared = ClientScriptManager()

    private let context = LuaContext()

    private var isItemScriptsLoaded = false
    private var isMonsterScriptsLoaded = false
    private var isSkillScriptsLoaded = false

    func itemDisplayName(_ itemID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        try? loadItemScriptsIfNeeded()

        guard let result = try? context.call("itemDisplayName", with: [itemID]) as? String else {
            return nil
        }

        guard let data = result.data(using: .isoLatin1) else {
            return nil
        }

        let string = String(data: data, encoding: ClientConfiguration.shared.encoding)
        return string
    }

    func itemResourceName(_ itemID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

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
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        try? loadItemScriptsIfNeeded()

        guard let result = try? context.call("itemDescription", with: [itemID]) as? [String] else {
            return nil
        }

        guard let data = result.joined(separator: "\n").data(using: .isoLatin1) else {
            return nil
        }

        let string = String(data: data, encoding: ClientConfiguration.shared.encoding)
        return string
    }

    func monsterResourceName(_ monsterID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        try? loadMonsterScriptsIfNeeded()

        let result = try? context.call("monsterResourceName", with: [monsterID]) as? String
        return result
    }

    func skillName(_ skillID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        try? loadSkillScriptsIfNeeded()

        guard let result = try? context.call("skillName", with: [skillID]) as? String else {
            return nil
        }

        guard let data = result.data(using: .isoLatin1) else {
            return nil
        }

        let string = String(data: data, encoding: ClientConfiguration.shared.encoding)
        return string
    }

    func skillDescription(_ skillID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        try? loadSkillScriptsIfNeeded()

        guard let result = try? context.call("skillDescription", with: [skillID]) as? [String] else {
            return nil
        }

        guard let data = result.joined(separator: "\n").data(using: .isoLatin1) else {
            return nil
        }

        let string = String(data: data, encoding: ClientConfiguration.shared.encoding)
        return string
    }

    private func loadItemScriptsIfNeeded() throws {
        guard !isItemScriptsLoaded else {
            return
        }

        let iteminfoURL = ClientBundle.shared.url.appendingPathComponent("System/iteminfo.lub")
        if let iteminfo = try? Data(contentsOf: iteminfoURL) {
            try context.load(iteminfo)
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

    private func loadMonsterScriptsIfNeeded() throws {
        guard !isMonsterScriptsLoaded else {
            return
        }

        try loadScript([
            GRF.Path(string: "data\\luafiles514\\lua files\\datainfo\\npcidentity.lub"),
            GRF.Path(string: "data\\LuaFiles514\\Lua Files\\Datainfo\\NPCIdentity.lub"),
        ])

        try loadScript([
            GRF.Path(string: "data\\luafiles514\\lua files\\datainfo\\jobname.lub"),
            GRF.Path(string: "data\\LuaFiles514\\Lua Files\\Datainfo\\jobName.lub"),
        ])

        try context.parse("""
        function monsterResourceName(monsterID)
            return JobNameTable[monsterID]
        end
        """)

        isMonsterScriptsLoaded = true
    }

    private func loadSkillScriptsIfNeeded() throws {
        guard !isSkillScriptsLoaded else {
            return
        }

        try loadScript([
            GRF.Path(string: "data\\luafiles514\\lua files\\skillinfoz\\jobinheritlist.lub"),
            GRF.Path(string: "data\\LuaFiles514\\Lua Files\\skillinfoz\\JobInheritList.lub"),
        ])

        try loadScript([
            GRF.Path(string: "data\\luafiles514\\lua files\\skillinfoz\\skillid.lub"),
            GRF.Path(string: "data\\LuaFiles514\\Lua Files\\skillinfoz\\SkillID.lub"),
        ])

        try loadScript([
            GRF.Path(string: "data\\luafiles514\\lua files\\skillinfoz\\skillinfolist.lub"),
            GRF.Path(string: "data\\LuaFiles514\\Lua Files\\skillinfoz\\SkillInfoList.lub"),
        ])

        try loadScript([
            GRF.Path(string: "data\\luafiles514\\lua files\\skillinfoz\\skilldescript.lub"),
            GRF.Path(string: "data\\LuaFiles514\\Lua Files\\skillinfoz\\SkillDescript.lub"),
        ])

        try context.parse("""
        function skillName(skillID)
            return SKILL_INFO_LIST[skillID]["SkillName"]
        end
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

        try context.load(data)
    }
}
