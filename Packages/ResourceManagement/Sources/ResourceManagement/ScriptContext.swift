//
//  ScriptContext.swift
//  ResourceManagement
//
//  Created by Leon Li on 2025/3/3.
//

@preconcurrency import Lua

final public class ScriptContext: Resource {
    let context: LuaContext
    let contextQueue: DispatchQueue

    init(context: LuaContext) {
        self.context = context
        self.contextQueue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.script-context")
    }

    public func identifiedItemResourceName(forItemID itemID: Int) -> String? {
        let result = call("identifiedItemResourceName", with: [itemID], to: String.self)
        return result
    }

    public func accessoryName(forAccessoryID accessoryID: Int) -> String? {
        let result = call("ReqAccName", with: [accessoryID], to: String.self)
        return result
    }

    public func jobName(forJobID jobID: Int) -> String? {
        let result = call("ReqJobName", with: [jobID], to: String.self)
        return result
    }

    public func robeName(forRobeID robeID: Int, checkEnglish: Bool) -> String? {
        let result = call("ReqRobSprName_V2", with: [robeID, checkEnglish], to: String.self)
        return result
    }

    public func shadowFactor(forJobID jobID: Int) -> Double? {
        let result = call("ReqshadowFactor", with: [jobID], to: Double.self)
        return result
    }

    public func statusIconName(forStatusID statusID: Int) -> String? {
        let result = call("statusIconName", with: [statusID], to: String.self)
        return result
    }

    public func weaponName(forWeaponID weaponID: Int) -> String? {
        let result = call("ReqWeaponName", with: [weaponID], to: String.self)
        return result
    }

    public func realWeaponID(forWeaponID weaponID: Int) -> Int? {
        let result = call("GetRealWeaponId", with: [weaponID], to: Int.self)
        return result
    }

    public func drawOnTop(forRobeID robeID: Int, genderID: Int, jobID: Int, actionIndex: Int, frameIndex: Int) -> Bool {
        let result = call("_New_DrawOnTop", with: [robeID, genderID, jobID, actionIndex, frameIndex], to: Bool.self)
        return result ?? false
    }

    public func isTopLayer(forRobeID robeID: Int) -> Bool {
        let result = call("IsTopLayer", with: [robeID], to: Bool.self)
        return result ?? false
    }

    private func call<T>(_ name: String, with args: [Any], to resultType: T.Type) -> T? {
        contextQueue.sync {
            do {
                let result = try context.call(name, with: args)
                return result as? T
            } catch {
                logger.warning("\(error)")
                return nil
            }
        }
    }
}

extension ResourceManager {
    public func scriptContext() async -> ScriptContext {
        let resourceIdentifier = "ScriptContext"

        if let phase = resources[resourceIdentifier] {
            return await phase.resource as! ScriptContext
        }

        let task = ResourceTask {
            let context = LuaContext()

            async let itemInfo = itemInfoScript()

            async let accessoryid = script(at: ["datainfo", "accessoryid"])
            async let accname = script(at: ["datainfo", "accname"])
            async let accname_f = script(at: ["datainfo", "accname_f"])

            async let jobidentity = script(at: ["datainfo", "jobidentity"])
            async let npcidentity = script(at: ["datainfo", "npcidentity"])
            async let jobname = script(at: ["datainfo", "jobname"])
            async let jobname_f = script(at: ["datainfo", "jobname_f"])

            async let shadowtable = script(at: ["datainfo", "shadowtable"])
            async let shadowtable_f = script(at: ["datainfo", "shadowtable_f"])

            async let spriterobeid = script(at: ["datainfo", "spriterobeid"])
            async let spriterobename = script(at: ["datainfo", "spriterobename"])
            async let spriterobename_f = script(at: ["datainfo", "spriterobename_f"])

            async let weapontable = script(at: ["datainfo", "weapontable"])
            async let weapontable_f = script(at: ["datainfo", "weapontable_f"])

            async let jobinheritlist = script(at: ["skillinfoz", "jobinheritlist"])
            async let skillid = script(at: ["skillinfoz", "skillid"])

            async let efstids = script(at: ["stateicon", "efstids"])
            async let stateiconimginfo = script(at: ["stateicon", "stateiconimginfo"])

            async let smalllayerdir_female = script(at: ["spreditinfo", "smalllayerdir_female"])
            async let smalllayerdir_male = script(at: ["spreditinfo", "smalllayerdir_male"])
            async let biglayerdir_female = script(at: ["spreditinfo", "biglayerdir_female"])
            async let biglayerdir_male = script(at: ["spreditinfo", "biglayerdir_male"])
            async let _2dlayerdir_f = script(at: ["spreditinfo", "2dlayerdir_f"])
            async let _new_smalllayerdir_female = script(at: ["spreditinfo", "_new_smalllayerdir_female"])
            async let _new_smalllayerdir_male = script(at: ["spreditinfo", "_new_smalllayerdir_male"])
            async let _new_biglayerdir_female = script(at: ["spreditinfo", "_new_biglayerdir_female"])
            async let _new_biglayerdir_male = script(at: ["spreditinfo", "_new_biglayerdir_male"])
            async let _new_2dlayerdir_f = script(at: ["spreditinfo", "_new_2dlayerdir_f"])

            async let offsetitempos_f = script(at: ["offsetitempos", "offsetitempos_f"])
            async let offsetitempos = script(at: ["offsetitempos", "offsetitempos"])

            await loadScript(itemInfo, in: context)

            await loadScript(accessoryid, in: context)
            await loadScript(accname, in: context)
            await loadScript(accname_f, in: context)

            await loadScript(jobidentity, in: context)
            await loadScript(npcidentity, in: context)
            await loadScript(jobname, in: context)
            await loadScript(jobname_f, in: context)

            await loadScript(shadowtable, in: context)
            await loadScript(shadowtable_f, in: context)

            await loadScript(spriterobeid, in: context)
            await loadScript(spriterobename, in: context)
            await loadScript(spriterobename_f, in: context)

            await loadScript(weapontable, in: context)
            await loadScript(weapontable_f, in: context)

            await loadScript(jobinheritlist, in: context)
            await loadScript(skillid, in: context)

            await loadScript(efstids, in: context)
            await loadScript(stateiconimginfo, in: context)

            await loadScript(smalllayerdir_female, in: context)
            await loadScript(smalllayerdir_male, in: context)
            await loadScript(biglayerdir_female, in: context)
            await loadScript(biglayerdir_male, in: context)
            await loadScript(_2dlayerdir_f, in: context)
            await loadScript(_new_smalllayerdir_female, in: context)
            await loadScript(_new_smalllayerdir_male, in: context)
            await loadScript(_new_biglayerdir_female, in: context)
            await loadScript(_new_biglayerdir_male, in: context)
            await loadScript(_new_2dlayerdir_f, in: context)

            await loadScript(offsetitempos_f, in: context)
            await loadScript(offsetitempos, in: context)

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
                logger.warning("\(error)")
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
                logger.warning("\(error)")
            }

            do {
                try context.parse("""
                function statusIconName(statusID)
                    local gold = StateIconImgList[PRIORITY_GOLD][statusID]
                    local red = StateIconImgList[PRIORITY_RED][statusID]
                    local blue = StateIconImgList[PRIORITY_BLUE][statusID]
                    local green = StateIconImgList[PRIORITY_GREEN][statusID]
                    local white = StateIconImgList[PRIORITY_WHITE][statusID]
                    if gold ~= nil then
                        return gold
                    elseif red ~= nil then
                        return red
                    elseif blue ~= nil then
                        return blue
                    elseif green ~= nil then
                        return green
                    elseif white ~= nil then
                        return white
                    else
                        return nil
                    end
                end
                function statusDescription(statusID)
                    return StateIconList[statusID]["descript"][1][1]
                end
                """)
            } catch {
                logger.warning("\(error)")
            }

            return ScriptContext(context: context)
        }

        resources[resourceIdentifier] = .inProgress(task)

        let scriptContext = await task.value as! ScriptContext

        resources[resourceIdentifier] = .loaded(scriptContext)

        return scriptContext
    }

    private func itemInfoScript() async -> Data? {
        do {
            let path = ResourcePath(components: ["System", "itemInfo.lub"])
            let data = try await contentsOfResource(at: path)
            return data
        } catch {
            logger.warning("\(error)")
            return nil
        }
    }

    private func script(at path: ResourcePath) async -> Data? {
        do {
            let path = ResourcePath.scriptDirectory.appending(path).appendingPathExtension("lub")
            let data = try await contentsOfResource(at: path)
            return data
        } catch {
            logger.warning("\(error)")
            return nil
        }
    }

    private func loadScript(_ script: Data?, in context: LuaContext) {
        guard let script else {
            return
        }

        do {
            try context.load(script)
        } catch {
            logger.warning("\(error)")
        }
    }
}
