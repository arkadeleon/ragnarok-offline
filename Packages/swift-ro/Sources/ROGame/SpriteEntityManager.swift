//
//  SpriteEntityManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/18.
//

import RealityKit
import RORendering

public actor SpriteEntityManager {
    var entitiesByJobID: [UniformJobID : SpriteEntity] = [:]

    public init() {
    }

    public func entity(forJobID jobID: UniformJobID) async -> SpriteEntity? {
        if let entity = entitiesByJobID[jobID] {
            let entityClone = await entity.clone(recursive: true)
            return entityClone
        }

        do {
            let actions = try await SpriteAction.actions(forJobID: jobID, configuration: SpriteConfiguration())
            let entity = await SpriteEntity(actions: actions)
            entitiesByJobID[jobID] = entity
            return entity
        } catch {
            return nil
        }
    }
}
