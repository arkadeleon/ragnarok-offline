//
//  ScriptContext.swift
//  RagnarokScript
//
//  Created by Leon Li on 2025/3/3.
//

@preconcurrency import RagnarokLua
import RagnarokResources

final public class ScriptContext: Resource {
    let context: LuaContext
    let contextQueue: DispatchQueue

    init(context: LuaContext) {
        self.context = context
        self.contextQueue = DispatchQueue(label: "com.github.arkadeleon.ragnarok-offline.script-context")
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
        await cachedResource(forIdentifier: "ScriptContext") { [self] in
            let contextLoader = ContextLoader()
            let context = await contextLoader.context(using: self)
            return ScriptContext(context: context)
        }
    }
}
