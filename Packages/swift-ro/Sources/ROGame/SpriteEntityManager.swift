//
//  SpriteEntityManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/18.
//

import RealityKit
import RORendering

public actor SpriteEntityManager {
    var entitiesByJobID: [Int : SpriteEntity] = [:]

    public init() {
    }

    public func entity(forJobID jobID: Int) async -> SpriteEntity? {
        if let entity = entitiesByJobID[jobID] {
            let entityClone = await entity.clone(recursive: true)
            return entityClone
        }

        do {
            let configuration = SpriteConfiguration(jobID: jobID)
            let composedSprite = await ComposedSprite(configuration: configuration, resourceManager: .default)
            let actions = try await SpriteAction.actions(for: composedSprite)
            let entity = await SpriteEntity(actions: actions)
            entitiesByJobID[jobID] = entity
            return entity
        } catch {
            return nil
        }
    }
}
