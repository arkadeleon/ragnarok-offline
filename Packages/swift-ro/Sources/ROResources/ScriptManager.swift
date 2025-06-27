//
//  ScriptManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/3.
//

@preconcurrency import Lua

public actor ScriptManager {
    let locale: Locale
    package let resourceManager: ResourceManager

    private var loadTask: Task<LuaContext, Never>? = nil

    public init(locale: Locale, resourceManager: ResourceManager) {
        self.locale = locale
        self.resourceManager = resourceManager
    }

    public func identifiedItemResourceName(forItemID itemID: Int) async -> String? {
        let result = await call("identifiedItemResourceName", with: [itemID], to: String.self)
        let itemResourceName = result?.transcoding(from: .isoLatin1, to: .koreanEUC)
        return itemResourceName
    }

    public func accessoryName(forAccessoryID accessoryID: Int) async -> String? {
        let result = await call("ReqAccName", with: [accessoryID], to: String.self)
        let accessoryName = result?.transcoding(from: .isoLatin1, to: .koreanEUC)
        return accessoryName
    }

    public func itemRandomOptionName(forItemRandomOptionID itemRandomOptionID: Int) async -> String? {
        let result = await call("GetVarOptionName", with: [itemRandomOptionID], to: String.self)
        let itemRandomOptionName = result?.transcoding(from: .isoLatin1, to: locale.language.preferredEncoding)
        return itemRandomOptionName
    }

    public func jobName(forJobID jobID: Int) async -> String? {
        let result = await call("ReqJobName", with: [jobID], to: String.self)
        return result
    }

    public func robeName(forRobeID robeID: Int, checkEnglish: Bool) async -> String? {
        let result = await call("ReqRobSprName_V2", with: [robeID, checkEnglish], to: String.self)
        let robeName = result?.transcoding(from: .isoLatin1, to: .koreanEUC)
        return robeName
    }

    public func shadowFactor(forJobID jobID: Int) async -> Double? {
        let result = await call("ReqshadowFactor", with: [jobID], to: Double.self)
        return result
    }

    public func localizedSkillName(forSkillID skillID: Int) async -> String? {
        let result = await call("GetSkillName", with: [skillID], to: String.self)
        let skillName = result?
            .transcoding(from: .isoLatin1, to: locale.language.preferredEncoding)
        return skillName
    }

    public func localizedSkillDescription(forSkillID skillID: Int) async -> String? {
        let result = await call("GetSkillDescript", with: [skillID], to: [String].self)
        let skillDescription = result?
            .joined(separator: "\n")
            .transcoding(from: .isoLatin1, to: locale.language.preferredEncoding)
        return skillDescription
    }

    public func weaponName(forWeaponID weaponID: Int) async -> String? {
        let result = await call("ReqWeaponName", with: [weaponID], to: String.self)
        let weaponName = result?.transcoding(from: .isoLatin1, to: .koreanEUC)
        return weaponName
    }

    public func realWeaponID(forWeaponID weaponID: Int) async -> Int? {
        let result = await call("GetRealWeaponId", with: [weaponID], to: Int.self)
        return result
    }

    public func drawOnTop(forRobeID robeID: Int, genderID: Int, jobID: Int, actionIndex: Int, frameIndex: Int) async -> Bool {
        let result = await call("_New_DrawOnTop", with: [robeID, genderID, jobID, actionIndex, frameIndex], to: Bool.self)
        return result ?? false
    }

    public func isTopLayer(forRobeID robeID: Int) async -> Bool {
        let result = await call("IsTopLayer", with: [robeID], to: Bool.self)
        return result ?? false
    }

    // MARK: - Load & Call

    private func call<T>(_ name: String, with args: [Any], to resultType: T.Type) async -> T? {
        let context = await loadContext()

        do {
            let result = try context.call(name, with: args)
            return result as? T
        } catch {
            logger.warning("\(error.localizedDescription)")
            return nil
        }
    }

    private func loadContext() async -> LuaContext {
        if let task = loadTask {
            return await task.value
        }

        let task = Task<LuaContext, Never> {
            let context = LuaContext()

            await loadLocalScript("itemInfo", locale: .korean, in: context)

            await loadScript(at: ["datainfo", "accessoryid"], in: context)
            await loadScript(at: ["datainfo", "accname"], in: context)
            await loadScript(at: ["datainfo", "accname_f"], in: context)

            await loadScript(at: ["datainfo", "enumvar"], in: context)
            await loadLocalScript("addrandomoptionnametable", locale: .korean, in: context)
            await loadScript(at: ["datainfo", "addrandomoption_f"], in: context)

            await loadScript(at: ["datainfo", "jobidentity"], in: context)
            await loadScript(at: ["datainfo", "npcidentity"], in: context)
            await loadScript(at: ["datainfo", "jobname"], in: context)
            await loadScript(at: ["datainfo", "jobname_f"], in: context)

            await loadScript(at: ["datainfo", "shadowtable"], in: context)
            await loadScript(at: ["datainfo", "shadowtable_f"], in: context)

            await loadScript(at: ["datainfo", "spriterobeid"], in: context)
            await loadScript(at: ["datainfo", "spriterobename"], in: context)
            await loadScript(at: ["datainfo", "spriterobename_f"], in: context)

            await loadScript(at: ["datainfo", "weapontable"], in: context)
            await loadScript(at: ["datainfo", "weapontable_f"], in: context)

            await loadScript(at: ["skillinfoz", "jobinheritlist"], in: context)
            await loadScript(at: ["skillinfoz", "skillid"], in: context)
            await loadLocalScript("skillinfolist", locale: locale, in: context)
            await loadLocalScript("skilldescript", locale: locale, in: context)
//            await loadScript(at: ["skillinfoz", "skillinfo_f"], in: context)

            await loadScript(at: ["spreditinfo", "smalllayerdir_female"], in: context)
            await loadScript(at: ["spreditinfo", "smalllayerdir_male"], in: context)
            await loadScript(at: ["spreditinfo", "biglayerdir_female"], in: context)
            await loadScript(at: ["spreditinfo", "biglayerdir_male"], in: context)
            await loadScript(at: ["spreditinfo", "2dlayerdir_f"], in: context)
            await loadScript(at: ["spreditinfo", "_new_smalllayerdir_female"], in: context)
            await loadScript(at: ["spreditinfo", "_new_smalllayerdir_male"], in: context)
            await loadScript(at: ["spreditinfo", "_new_biglayerdir_female"], in: context)
            await loadScript(at: ["spreditinfo", "_new_biglayerdir_male"], in: context)
            await loadScript(at: ["spreditinfo", "_new_2dlayerdir_f"], in: context)

            await loadScript(at: ["offsetitempos", "offsetitempos_f"], in: context)
            await loadScript(at: ["offsetitempos", "offsetitempos"], in: context)

            do {
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
            } catch {
                logger.warning("\(error.localizedDescription)")
            }

            do {
                try context.parse("""
                function GetSkillName(skillID)
                    return SKILL_INFO_LIST[skillID]["SkillName"]
                end
                function GetSkillDescript(skillID)
                    return SKILL_DESCRIPT[skillID]
                end
                """)
            } catch {
                logger.warning("\(error.localizedDescription)")
            }

            return context
        }
        loadTask = task

        return await task.value
    }

    private func loadScript(at path: ResourcePath, in context: LuaContext) async {
        do {
            let path = ResourcePath.scriptDirectory.appending(path).appendingPathExtension("lub")
            let data = try await resourceManager.contentsOfResource(at: path)
            try context.load(data)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }

    private func loadLocalScript(_ name: String, locale: Locale, in context: LuaContext) async {
        guard let url = Bundle.module.url(forResource: name, withExtension: "lub", locale: locale) else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            try context.load(data)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }
}
