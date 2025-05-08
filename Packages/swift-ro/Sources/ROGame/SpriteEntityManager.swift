//
//  SpriteEntityManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/18.
//

import RealityKit
import RORendering
import ROResources

public actor SpriteEntityManager {
    public let resourceManager: ResourceManager
    public let scriptManager: ScriptManager

    private var entitiesByJobID: [Int : SpriteEntity] = [:]

    public init(resourceManager: ResourceManager, scriptManager: ScriptManager) {
        self.resourceManager = resourceManager
        self.scriptManager = scriptManager
    }

    public func entity(forJobID jobID: Int) async -> SpriteEntity? {
        if let entity = entitiesByJobID[jobID] {
            let entityClone = await entity.clone(recursive: true)
            return entityClone
        }

        do {
            let configuration = ComposedSprite.Configuration(jobID: jobID)
            let composedSprite = await ComposedSprite(
                configuration: configuration,
                resourceManager: resourceManager,
                scriptManager: scriptManager
            )
            let actions = try await SpriteAction.actions(for: composedSprite)
            let entity = await SpriteEntity(actions: actions)
            entitiesByJobID[jobID] = entity
            return entity
        } catch {
            return nil
        }
    }
}
