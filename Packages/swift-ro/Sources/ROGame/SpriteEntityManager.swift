//
//  SpriteEntityManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/18.
//

import RealityKit
import RORendering

public actor SpriteEntityManager {
    var entitiesByJob: [Int : SpriteEntity] = [:]

    public init() {
    }

    public func entity(forJob job: Int) async -> SpriteEntity? {
        if let entity = entitiesByJob[job] {
            let entityClone = await entity.clone(recursive: true)
            return entityClone
        }

        do {
            let configuration = SpriteConfiguration(job: job)
            let actions = try await SpriteAction.actions(forConfiguration: configuration)
            let entity = await SpriteEntity(actions: actions)
            entitiesByJob[job] = entity
            return entity
        } catch {
            return nil
        }
    }
}
