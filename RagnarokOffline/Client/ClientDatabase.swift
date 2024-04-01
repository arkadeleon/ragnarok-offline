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

    private var identifiedItemDisplayNameTable: [Int : Data] = [:]
    private var identifiedItemResourceNameTable: [Int : Data] = [:]
    private var identifiedItemDescriptionTable: [Int : Data] = [:]

    private var mapNameTable: [String : Data] = [:]

    private var isItemScriptsLoaded = false
    private var isIdentifiedItemDisplayNameTableLoaded = false
    private var isIdentifiedItemResourceNameTableLoaded = false
    private var isIdentifiedItemDescriptionTableLoaded = false
    private var isMonsterScriptsLoaded = false
    private var isSkillScriptsLoaded = false
    private var isMapNameTableLoaded = false

    // MARK: - Item

    func identifiedItemDisplayName(_ itemID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        switch ClientSettings.shared.itemInfoSource {
        case .lua:
            try? loadItemScriptsIfNeeded()

            guard let result = try? context.call("identifiedItemDisplayName", with: [itemID]) as? String else {
                return nil
            }

            let encoding = ClientSettings.shared.serviceType.stringEncoding
            let itemDisplayName = result.data(using: .isoLatin1)?.string(using: encoding)
            return itemDisplayName
        case .txt:
            try? loadIdentifiedItemDisplayNameTableIfNeeded()

            let encoding = ClientSettings.shared.serviceType.stringEncoding
            let itemDisplayName = identifiedItemDisplayNameTable[itemID]?.string(using: encoding)
            return itemDisplayName
        }
    }

    func identifiedItemResourceName(_ itemID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        switch ClientSettings.shared.itemInfoSource {
        case .lua:
            try? loadItemScriptsIfNeeded()

            guard let result = try? context.call("identifiedItemResourceName", with: [itemID]) as? String else {
                return nil
            }

            let itemResourceName = result.data(using: .isoLatin1)?.string(using: .koreanEUC)
            return itemResourceName
        case .txt:
            try? loadIdentifiedItemResourceNameTableIfNeeded()

            let itemResourceName = identifiedItemResourceNameTable[itemID]?.string(using: .koreanEUC)
            return itemResourceName
        }
    }

    func identifiedItemDescription(_ itemID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        switch ClientSettings.shared.itemInfoSource {
        case .lua:
            try? loadItemScriptsIfNeeded()

            guard let result = try? context.call("identifiedItemDescription", with: [itemID]) as? [String] else {
                return nil
            }

            let encoding = ClientSettings.shared.serviceType.stringEncoding
            let itemDescription = result.joined(separator: "\n").data(using: .isoLatin1)?.string(using: encoding)
            return itemDescription
        case .txt:
            try? loadIdentifiedItemDescriptionTableIfNeeded()

            let encoding = ClientSettings.shared.serviceType.stringEncoding
            let itemDescription = identifiedItemDescriptionTable[itemID]?.string(using: encoding)
            return itemDescription
        }
    }

    private func loadItemScriptsIfNeeded() throws {
        guard !isItemScriptsLoaded else {
            return
        }

        let iteminfoURL = ClientResourceBundle.shared.url.appendingPathComponent("System/iteminfo.lub")
        if let iteminfo = try? Data(contentsOf: iteminfoURL) {
            try context.load(iteminfo)
        }

        try context.parse("""
        function unidentifiedItemDisplayName(itemID)
            return tbl[itemID]["unidentifiedDisplayName"]
        end
        function unidentifiedItemResourceName(itemID)
            return tbl[itemID]["unidentifiedResourceName"]
        end
        function unidentifiedItemDescription(itemID)
            return tbl[itemID]["unidentifiedDescriptionName"]
        end
        function identifiedItemDisplayName(itemID)
            return tbl[itemID]["identifiedDisplayName"]
        end
        function identifiedItemResourceName(itemID)
            return tbl[itemID]["identifiedResourceName"]
        end
        function identifiedItemDescription(itemID)
            return tbl[itemID]["identifiedDescriptionName"]
        end
        function itemSlotCount(itemID)
            return tbl[itemID]["slotCount"]
        end
        """)

        isItemScriptsLoaded = true
    }

    private func loadIdentifiedItemDisplayNameTableIfNeeded() throws {
        guard !isIdentifiedItemDisplayNameTableLoaded else {
            return
        }

        let file = ClientResourceBundle.shared.identifiedItemDisplayNameTable()
        guard let data = file.contents() else {
            return
        }

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

    private func loadIdentifiedItemResourceNameTableIfNeeded() throws {
        guard !isIdentifiedItemResourceNameTableLoaded else {
            return
        }

        let file = ClientResourceBundle.shared.identifiedItemResourceNameTable()
        guard let data = file.contents() else {
            return
        }

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
                let itemResourceName = String(columns[1])
                if let itemID {
                    identifiedItemResourceNameTable[itemID] = itemResourceName.data(using: .isoLatin1)
                }
            }
        }

        isIdentifiedItemResourceNameTableLoaded = true
    }

    private func loadIdentifiedItemDescriptionTableIfNeeded() throws {
        guard !isIdentifiedItemDescriptionTableLoaded else {
            return
        }

        let file = ClientResourceBundle.shared.identifiedItemDescriptionTable()
        guard let data = file.contents() else {
            return
        }

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

    // MARK: - Monster

    func monsterResourceName(_ monsterID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        try? loadMonsterScriptsIfNeeded()

        let result = try? context.call("monsterResourceName", with: [monsterID]) as? String
        return result
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

    // MARK: - Skill

    func skillDisplayName(_ skillID: Int) -> String? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        try? loadSkillScriptsIfNeeded()

        guard let result = try? context.call("skillName", with: [skillID]) as? String else {
            return nil
        }

        let encoding = ClientSettings.shared.serviceType.stringEncoding
        let skillName = result.data(using: .isoLatin1)?.string(using: encoding)
        return skillName
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

        let encoding = ClientSettings.shared.serviceType.stringEncoding
        let skillDescription = result.joined(separator: "\n").data(using: .isoLatin1)?.string(using: encoding)
        return skillDescription
    }

    private func loadSkillScriptsIfNeeded() throws {
        guard !isSkillScriptsLoaded else {
            return
        }

        try loadScript([
            GRF.Path(string: "data\\lua files\\skillinfoz\\jobinheritlist.lub"),
            GRF.Path(string: "data\\luafiles514\\lua files\\skillinfoz\\jobinheritlist.lub"),
            GRF.Path(string: "data\\LuaFiles514\\Lua Files\\skillinfoz\\JobInheritList.lub"),
        ])

        try loadScript([
            GRF.Path(string: "data\\lua files\\skillinfoz\\skillid.lub"),
            GRF.Path(string: "data\\luafiles514\\lua files\\skillinfoz\\skillid.lub"),
            GRF.Path(string: "data\\LuaFiles514\\Lua Files\\skillinfoz\\SkillID.lub"),
        ])

        try loadScript([
            GRF.Path(string: "data\\lua files\\skillinfoz\\skillinfolist.lub"),
            GRF.Path(string: "data\\luafiles514\\lua files\\skillinfoz\\skillinfolist.lub"),
            GRF.Path(string: "data\\LuaFiles514\\Lua Files\\skillinfoz\\SkillInfoList.lub"),
        ])

        try loadScript([
            GRF.Path(string: "data\\lua files\\skillinfoz\\skilldescript.lub"),
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

    // MARK: - Map

    func mapDisplayName(_ mapName: String) -> String? {
        try? loadMapNameTableIfNeeded()

        let encoding = ClientSettings.shared.serviceType.stringEncoding
        let mapName = mapNameTable[mapName]?.string(using: encoding)
        return mapName
    }

    private func loadMapNameTableIfNeeded() throws {
        guard !isMapNameTableLoaded else {
            return
        }

        let file = ClientResourceBundle.shared.mapNameTableFile()
        guard let data = file.contents() else {
            return
        }

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
                let mapName = String(columns[0]).replacingOccurrences(of: ".rsw", with: "")
                let mapDisplayName = String(columns[1])
                mapNameTable[mapName] = mapDisplayName.data(using: .isoLatin1)
            }
        }

        isMapNameTableLoaded = true
    }

    // MARK: -

    private func loadScript(_ paths: [GRF.Path]) throws {
        var data: Data?
        for path in paths {
            data = try? ClientResourceBundle.shared.grf.contentsOfEntry(at: path)
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
