//
//  ScriptContext.swift
//  RagnarokScript
//
//  Created by Leon Li on 2025/3/3.
//

import RagnarokLua
import RagnarokResources

final public class ScriptContext: Resource {
    let context: LuaContext

    init(context: LuaContext) {
        self.context = context
    }

    public func accessoryName(forAccessoryID accessoryID: Int) -> String? {
        // The script answers with an empty string for an accessory it has no name for.
        let result = call("ReqAccName", with: [.number(Double(accessoryID))]).stringValue
        return result?.isEmpty == false ? result : nil
    }

    public func jobName(forJobID jobID: Int) -> String? {
        let result = call("ReqJobName", with: [.number(Double(jobID))]).stringValue
        return result
    }

    public func robeName(forRobeID robeID: Int, checkEnglish: Bool) -> String? {
        // The script answers with an empty string for a robe it has no name for.
        let result = call("ReqRobSprName_V2", with: [.number(Double(robeID)), .boolean(checkEnglish)]).stringValue
        return result?.isEmpty == false ? result : nil
    }

    public func shadowFactor(forJobID jobID: Int) -> Double? {
        let result = call("ReqshadowFactor", with: [.number(Double(jobID))]).numberValue
        return result
    }

    public func statusIconName(forStatusID statusID: Int) -> String? {
        let result = call("statusIconName", with: [.number(Double(statusID))]).stringValue
        return result
    }

    public func weaponName(forWeaponID weaponID: Int) -> String? {
        // The script answers with an empty string for a weapon it has no name for.
        let result = call("ReqWeaponName", with: [.number(Double(weaponID))]).stringValue
        return result?.isEmpty == false ? result : nil
    }

    public func realWeaponID(forWeaponID weaponID: Int) -> Int? {
        let result = call("GetRealWeaponId", with: [.number(Double(weaponID))]).intValue
        return result
    }

    public func drawOnTop(forRobeID robeID: Int, genderID: Int, jobID: Int, actionIndex: Int, frameIndex: Int) -> Bool {
        let arguments: [LuaValue] = [robeID, genderID, jobID, actionIndex, frameIndex].map { .number(Double($0)) }
        let result = call("_New_DrawOnTop", with: arguments).booleanValue
        return result ?? false
    }

    public func isTopLayer(forRobeID robeID: Int) -> Bool {
        let result = call("IsTopLayer", with: [.number(Double(robeID))]).booleanValue
        return result ?? false
    }

    private func call(_ name: String, with arguments: [LuaValue]) -> LuaValue {
        do {
            return try context.call(name, with: arguments)
        } catch {
            logger.warning("\(error)")
            return .nil
        }
    }
}

extension ResourceManager {
    public func scriptContext() async -> ScriptContext {
        await cachedResource(forIdentifier: "ScriptContext") { [self] in
            let contextLoader = ContextLoader()
            let context = await contextLoader.context(using: self)
            return ScriptContext(context: context)
        }
    }
}
