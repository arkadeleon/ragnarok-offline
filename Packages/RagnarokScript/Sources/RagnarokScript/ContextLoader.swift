//
//  ContextLoader.swift
//  RagnarokScript
//
//  Created by Leon Li on 2026/6/23.
//

@preconcurrency import RagnarokLua
import RagnarokResources

actor ContextLoader {
    static let shared = ContextLoader()

    private enum Phase {
        case inProgress(Task<LuaContext, Never>)
        case loaded(LuaContext)
    }

    private var phase: ContextLoader.Phase?

    func context(using resourceManager: ResourceManager) async -> LuaContext {
        if let phase {
            switch phase {
            case .inProgress(let task):
                return await task.value
            case .loaded(let value):
                return value
            }
        }

        let task = Task {
            await load(using: resourceManager)
        }
        phase = .inProgress(task)

        let value = await task.value
        phase = .loaded(value)
        return value
    }

    private func load(using resourceManager: ResourceManager) async -> LuaContext {
        let context = LuaContext()

        async let accessoryid = resourceManager.script(at: ["datainfo", "accessoryid"])
        async let accname = resourceManager.script(at: ["datainfo", "accname"])
        async let accname_f = resourceManager.script(at: ["datainfo", "accname_f"])

        async let jobidentity = resourceManager.script(at: ["datainfo", "jobidentity"])
        async let npcidentity = resourceManager.script(at: ["datainfo", "npcidentity"])
        async let jobname = resourceManager.script(at: ["datainfo", "jobname"])
        async let jobname_f = resourceManager.script(at: ["datainfo", "jobname_f"])

        async let shadowtable = resourceManager.script(at: ["datainfo", "shadowtable"])
        async let shadowtable_f = resourceManager.script(at: ["datainfo", "shadowtable_f"])

        async let spriterobeid = resourceManager.script(at: ["datainfo", "spriterobeid"])
        async let spriterobename = resourceManager.script(at: ["datainfo", "spriterobename"])
        async let spriterobename_f = resourceManager.script(at: ["datainfo", "spriterobename_f"])

        async let weapontable = resourceManager.script(at: ["datainfo", "weapontable"])
        async let weapontable_f = resourceManager.script(at: ["datainfo", "weapontable_f"])

        async let jobinheritlist = resourceManager.script(at: ["skillinfoz", "jobinheritlist"])
        async let skillid = resourceManager.script(at: ["skillinfoz", "skillid"])

        async let efstids = resourceManager.script(at: ["stateicon", "efstids"])
        async let stateiconimginfo = resourceManager.script(at: ["stateicon", "stateiconimginfo"])

        async let smalllayerdir_female = resourceManager.script(at: ["spreditinfo", "smalllayerdir_female"])
        async let smalllayerdir_male = resourceManager.script(at: ["spreditinfo", "smalllayerdir_male"])
        async let biglayerdir_female = resourceManager.script(at: ["spreditinfo", "biglayerdir_female"])
        async let biglayerdir_male = resourceManager.script(at: ["spreditinfo", "biglayerdir_male"])
        async let _2dlayerdir_f = resourceManager.script(at: ["spreditinfo", "2dlayerdir_f"])
        async let _new_smalllayerdir_female = resourceManager.script(at: ["spreditinfo", "_new_smalllayerdir_female"])
        async let _new_smalllayerdir_male = resourceManager.script(at: ["spreditinfo", "_new_smalllayerdir_male"])
        async let _new_biglayerdir_female = resourceManager.script(at: ["spreditinfo", "_new_biglayerdir_female"])
        async let _new_biglayerdir_male = resourceManager.script(at: ["spreditinfo", "_new_biglayerdir_male"])
        async let _new_2dlayerdir_f = resourceManager.script(at: ["spreditinfo", "_new_2dlayerdir_f"])

        async let offsetitempos_f = resourceManager.script(at: ["offsetitempos", "offsetitempos_f"])
        async let offsetitempos = resourceManager.script(at: ["offsetitempos", "offsetitempos"])

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

        return context
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

extension ResourceManager {
    fileprivate func script(at path: ResourcePath) async -> Data? {
        do {
            let path = ResourcePath.scriptDirectory.appending(path: path).appendingPathExtension("lub")
            let data = try await contentsOfResource(at: path)
            return data
        } catch {
            logger.warning("\(error)")
            return nil
        }
    }
}
