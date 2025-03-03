//
//  ScriptManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/3.
//

@preconcurrency import Lua

public actor ScriptManager {
    public static let `default` = ScriptManager(resourceManager: .default)

    public let resourceManager: ResourceManager

    private let context = LuaContext()
    private var isLoaded = false

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    public func shadowFactor(forJobID jobID: Int) async -> Double? {
        let result: Double? = await call("ReqshadowFactor", with: [jobID])
        return result
    }

    private func call<T>(_ name: String, with args: [Any]) async -> T? {
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

        await load(contentsAt: ["datainfo", "jobidentity.lub"])
        await load(contentsAt: ["datainfo", "npcidentity.lub"])
        await load(contentsAt: ["datainfo", "shadowtable.lub"])
        await load(contentsAt: ["datainfo", "shadowtable_f.lub"])

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
}
