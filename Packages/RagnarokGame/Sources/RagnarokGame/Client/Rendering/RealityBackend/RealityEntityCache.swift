//
//  RealityEntityCache.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import RagnarokConstants
import RagnarokModels
import RagnarokSprite
import RealityKit

enum RealityEntityPhase {
    case inProgress(Task<Entity, any Error>)
    case loaded(Entity)

    var entity: Entity {
        get async throws {
            switch self {
            case .inProgress(let task):
                try await task.value
            case .loaded(let entity):
                entity
            }
        }
    }
}

@MainActor
final class RealityEntityCache {
    private let factory: RealitySpriteNodeFactory

    private var objectEntitiesByID: [UInt32 : RealityEntityPhase] = [:]
    private var itemEntitiesByID: [UInt32 : RealityEntityPhase] = [:]
    private var templateEntitiesByJobID: [Int : RealityEntityPhase] = [:]

    init(factory: RealitySpriteNodeFactory) {
        self.factory = factory
    }

    func addObjectEntity(_ entity: Entity, forObjectID objectID: UInt32) {
        objectEntitiesByID[objectID] = .loaded(entity)
    }

    func objectEntity(forObjectID objectID: UInt32) async throws -> Entity? {
        if let phase = objectEntitiesByID[objectID] {
            try await phase.entity
        } else {
            nil
        }
    }

    func loadedObjectEntity(forObjectID objectID: UInt32) -> Entity? {
        guard let phase = objectEntitiesByID[objectID] else {
            return nil
        }

        switch phase {
        case .loaded(let entity):
            return entity
        case .inProgress:
            return nil
        }
    }

    func removeObjectEntity(forObjectID objectID: UInt32) async throws {
        if let phase = objectEntitiesByID.removeValue(forKey: objectID) {
            let entity = try await phase.entity
            entity.removeFromParent()
        }
    }

    func objectEntity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        let job = CharacterJob(rawValue: mapObject.job)
        if job.isPlayer {
            return try await playerEntity(for: mapObject)
        } else {
            return try await nonPlayerEntity(for: mapObject)
        }
    }

    private func playerEntity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        if let phase = objectEntitiesByID[mapObject.objectID] {
            return try await (phase.entity, false)
        }

        let task = Task {
            try await factory.makeMapObjectEntity(for: mapObject)
        }
        objectEntitiesByID[mapObject.objectID] = .inProgress(task)

        let entity = try await task.value
        objectEntitiesByID[mapObject.objectID] = .loaded(entity)

        return (entity, true)
    }

    private func nonPlayerEntity(for mapObject: MapObject) async throws -> (entity: Entity, isNew: Bool) {
        if let phase = objectEntitiesByID[mapObject.objectID] {
            return try await (phase.entity, false)
        }

        if let templatePhase = templateEntitiesByJobID[mapObject.job] {
            let cloneTask = Task {
                let templateEntity = try await templatePhase.entity
                return templateEntity.clone(recursive: true)
            }
            objectEntitiesByID[mapObject.objectID] = .inProgress(cloneTask)

            let clonedEntity = try await cloneTask.value
            objectEntitiesByID[mapObject.objectID] = .loaded(clonedEntity)

            return (clonedEntity, true)
        }

        let templateTask = Task {
            try await factory.makeMapObjectEntity(for: mapObject)
        }
        templateEntitiesByJobID[mapObject.job] = .inProgress(templateTask)

        let templateEntity = try await templateTask.value
        templateEntitiesByJobID[mapObject.job] = .loaded(templateEntity)

        let clonedEntity = templateEntity.clone(recursive: true)
        objectEntitiesByID[mapObject.objectID] = .loaded(clonedEntity)

        return (clonedEntity, true)
    }

    func itemEntity(for mapItem: MapItem) async throws -> Entity {
        if let phase = itemEntitiesByID[mapItem.objectID] {
            return try await phase.entity
        }

        let task = Task {
            try await factory.makeMapItemEntity(for: mapItem)
        }
        itemEntitiesByID[mapItem.objectID] = .inProgress(task)

        let entity = try await task.value
        itemEntitiesByID[mapItem.objectID] = .loaded(entity)
        return entity
    }

    func removeItemEntity(forObjectID objectID: UInt32) async throws {
        if let phase = itemEntitiesByID.removeValue(forKey: objectID) {
            let entity = try await phase.entity
            entity.removeFromParent()
        }
    }
}
