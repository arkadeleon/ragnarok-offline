//
//  RealityEntityCache.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import RagnarokConstants
import RagnarokModels
import RagnarokResources
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
    private let resourceManager: ResourceManager

    private(set) var objectEntities: [GameObjectID : Entity] = [:]
    private(set) var itemEntities: [GameObjectID : Entity] = [:]

    private var templateEntitiesByConfiguration: [ComposedSprite.Configuration : RealityEntityPhase] = [:]
    private var templateEntitiesByItemID: [Int : RealityEntityPhase] = [:]

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func objectEntity(for object: MapSceneObject) -> Entity {
        if let entity = objectEntities[object.objectID] {
            return entity
        }

        let entity = Entity()
        objectEntities[object.objectID] = entity
        return entity
    }

    func removeObjectEntity(for objectID: GameObjectID) {
        if let entity = objectEntities.removeValue(forKey: objectID) {
            entity.removeFromParent()
        }
    }

    func objectSpriteEntity(for configuration: ComposedSprite.Configuration) async throws -> Entity {
        if let templatePhase = templateEntitiesByConfiguration[configuration] {
            let templateEntity = try await templatePhase.entity
            return templateEntity.clone(recursive: true)
        }

        let templateTask = Task<Entity, any Error> {
            let spriteEntity = try await SpriteEntity(forConfiguration: configuration, using: resourceManager)
            spriteEntity.name = "sprite"
            return spriteEntity
        }
        templateEntitiesByConfiguration[configuration] = .inProgress(templateTask)

        do {
            let templateEntity = try await templateTask.value
            templateEntitiesByConfiguration[configuration] = .loaded(templateEntity)
            return templateEntity.clone(recursive: true)
        } catch {
            templateEntitiesByConfiguration.removeValue(forKey: configuration)
            throw error
        }
    }

    func itemEntity(for item: MapSceneItem) -> Entity {
        if let entity = itemEntities[item.objectID] {
            return entity
        }

        let entity = Entity()
        itemEntities[item.objectID] = entity
        return entity
    }

    func removeItemEntity(for objectID: GameObjectID) {
        if let entity = itemEntities.removeValue(forKey: objectID) {
            entity.removeFromParent()
        }
    }

    func itemSpriteEntity(forItemID itemID: Int) async throws -> Entity {
        if let templatePhase = templateEntitiesByItemID[itemID] {
            let templateEntity = try await templatePhase.entity
            return templateEntity.clone(recursive: true)
        }

        let templateTask = Task<Entity, any Error> {
            let spriteEntity = try await SpriteEntity(forItemID: itemID, using: resourceManager)
            spriteEntity.name = "sprite"
            return spriteEntity
        }
        templateEntitiesByItemID[itemID] = .inProgress(templateTask)

        do {
            let templateEntity = try await templateTask.value
            templateEntitiesByItemID[itemID] = .loaded(templateEntity)
            return templateEntity.clone(recursive: true)
        } catch {
            templateEntitiesByItemID.removeValue(forKey: itemID)
            throw error
        }
    }

    func clear() {
        for entity in objectEntities.values {
            entity.removeFromParent()
        }
        objectEntities.removeAll()

        for entity in itemEntities.values {
            entity.removeFromParent()
        }
        itemEntities.removeAll()

        for phase in templateEntitiesByConfiguration.values {
            if case .inProgress(let task) = phase {
                task.cancel()
            }
        }
        templateEntitiesByConfiguration.removeAll()

        for phase in templateEntitiesByItemID.values {
            if case .inProgress(let task) = phase {
                task.cancel()
            }
        }
        templateEntitiesByItemID.removeAll()
    }
}
