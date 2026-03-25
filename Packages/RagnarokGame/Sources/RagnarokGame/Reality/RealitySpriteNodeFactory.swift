//
//  RealitySpriteNodeFactory.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import RagnarokModels
import RagnarokResources
import RealityKit

@MainActor
final class RealitySpriteNodeFactory {
    private let resourceManager: ResourceManager

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    func makeMapObjectEntity(for mapObject: MapObject) async throws -> Entity {
        try await Entity(from: mapObject, resourceManager: resourceManager)
    }

    func makeMapItemEntity(for item: MapItem) async throws -> Entity {
        try await Entity(from: item, resourceManager: resourceManager)
    }
}
