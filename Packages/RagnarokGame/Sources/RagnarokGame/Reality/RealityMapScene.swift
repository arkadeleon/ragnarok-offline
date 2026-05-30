//
//  RealityMapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if os(visionOS)

import Foundation
import RagnarokResources
import RealityKit

public final class RealityMapScene: GameMapScene {
    public let mapName: String

    let rootEntity = Entity()

    private let worldCameraEntity = Entity()
    private var tileSelectorEntity: Entity?

    let spriteEntityManager: SpriteEntityManager
    private var tileEntityManager: TileEntityManager?
    private var pathFinder: PathFinder?

    private let resourceManager: ResourceManager

    init(mapName: String, resourceManager: ResourceManager) {
        self.mapName = mapName
        self.resourceManager = resourceManager
        self.spriteEntityManager = SpriteEntityManager(resourceManager: resourceManager)

        registerComponents()
    }

    public func load(progress: Progress) async {
    }

    public func unload() {
        rootEntity.children.removeAll()
        tileEntityManager = nil
        pathFinder = nil
    }

    private func registerComponents() {
        GridPositionComponent.registerComponent()
        MapObjectComponent.registerComponent()
        MapItemComponent.registerComponent()
        HealthPointsComponent.registerComponent()
        SpellPointsComponent.registerComponent()

        WalkingComponent.registerComponent()
        WalkingSystem.registerSystem()
        TileComponent.registerComponent()

        SpriteActionComponent.registerComponent()
        SpriteActionSystem.registerSystem()
        SpriteAnimationComponent.registerComponent()
        SpriteAnimationTimingComponent.registerComponent()
        SpriteAnimationLibraryComponent.registerComponent()
        SpriteAnimationSystem.registerSystem()
        SpriteBillboardComponent.registerComponent()
        SpriteBillboardSystem.registerSystem()

        PlaySpriteAnimationAction.registerAction()
        PlaySpriteAnimationActionHandler.register { _ in
            PlaySpriteAnimationActionHandler()
        }
    }
}

#endif
