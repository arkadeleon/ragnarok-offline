//
//  SpriteEntityManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/18.
//

import RealityKit
import RORendering

public actor SpriteEntityManager {
    var entitiesByJob: [UniformJob : SpriteEntity] = [:]

    public init() {
    }

    public func entity(forJob job: UniformJob) async -> SpriteEntity? {
        if let entity = entitiesByJob[job] {
            let entityClone = await entity.clone(recursive: true)
            return entityClone
        }

        do {
            let actions = try await SpriteAction.actions(forJob: job, configuration: SpriteConfiguration())
            let entity = await SpriteEntity(actions: actions)
            entitiesByJob[job] = entity
            return entity
        } catch {
            return nil
        }
    }
}
