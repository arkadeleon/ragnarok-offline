//
//  ScriptManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/3.
//

@preconcurrency import Lua

public actor ScriptManager {
    public static let `default` = ScriptManager(locale: .current, resourceManager: .default)

    public let locale: Locale
    public let resourceManager: ResourceManager

    private let context = LuaContext()
    private var isLoaded = false

    public init(locale: Locale, resourceManager: ResourceManager) {
        self.locale = locale
        self.resourceManager = resourceManager
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

    // MARK: - Load & Call

    private func call<T>(_ name: String, with args: [Any], to resultType: T.Type) async -> T? {
        await loadScripts()

        do {
            let result = try context.call(name, with: args)
            return result as? T
        } catch {
            logger.warning("\(error.localizedDescription)")
            return nil
        }
    }

    private func loadScripts() async {
        if isLoaded {
            return
        }

        await load(contentsAt: ["datainfo", "accessoryid.lub"])
        await load(contentsAt: ["datainfo", "accname.lub"])
        await load(contentsAt: ["datainfo", "accname_f.lub"])

        await load(contentsAt: ["datainfo", "enumvar.lub"])
        await loadLocalizedScript("addrandomoptionnametable")
        await load(contentsAt: ["datainfo", "addrandomoption_f.lub"])

        await load(contentsAt: ["datainfo", "jobidentity.lub"])
        await load(contentsAt: ["datainfo", "npcidentity.lub"])
        await load(contentsAt: ["datainfo", "jobname.lub"])
        await load(contentsAt: ["datainfo", "jobname_f.lub"])

        await load(contentsAt: ["datainfo", "shadowtable.lub"])
        await load(contentsAt: ["datainfo", "shadowtable_f.lub"])

        await load(contentsAt: ["datainfo", "spriterobeid.lub"])
        await load(contentsAt: ["datainfo", "spriterobename.lub"])
        await load(contentsAt: ["datainfo", "spriterobename_f.lub"])

        await load(contentsAt: ["datainfo", "weapontable.lub"])
        await load(contentsAt: ["datainfo", "weapontable_f.lub"])

        await load(contentsAt: ["skillinfoz", "jobinheritlist.lub"])
        await load(contentsAt: ["skillinfoz", "skillid.lub"])
        await loadLocalizedScript("skillinfolist")
        await loadLocalizedScript("skilldescript")
//        await load(contentsAt: ["skillinfoz", "skillinfo_f.lub"])

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

        isLoaded = true
    }

    private func load(contentsAt path: ResourcePath) async {
        do {
            let path = ResourcePath.scriptPath + path
            let data = try await resourceManager.contentsOfResource(at: path)
            try context.load(data)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }

    private func loadLocalizedScript(_ name: String) async {
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
