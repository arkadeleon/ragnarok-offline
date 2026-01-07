//
//  SpriteEntity.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/2/22.
//

import Foundation
import RagnarokModels
import RagnarokResources
import RagnarokSprite
import RealityKit
import SGLMath

class SpriteEntity: Entity {
    required init() {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)

        let hoverEffectComponent = HoverEffectComponent(.highlight(.default))
        components.set(hoverEffectComponent)

        let shadowComponent = DynamicLightShadowComponent(castsShadow: false)
        components.set(shadowComponent)
    }

    convenience init(animation: SpriteAnimation) {
        self.init()

        let spriteComponent = SpriteAnimationsComponent(animation: animation)
        components.set(spriteComponent)
    }

    convenience init(animations: [String : SpriteAnimation]) {
        self.init()

        let spriteComponent = SpriteAnimationsComponent(animations: animations)
        components.set(spriteComponent)
    }
}

extension Entity {
    convenience init(from mapObject: MapObject, resourceManager: ResourceManager) async throws {
        self.init()

        let configuration = ComposedSprite.Configuration(mapObject: mapObject)
        let composedSprite = try await ComposedSprite(configuration: configuration, resourceManager: resourceManager)
        let animations = await SpriteAnimation.animations(for: composedSprite)

        let spriteEntity = SpriteEntity(animations: animations)
        spriteEntity.name = "sprite"
        spriteEntity.orientation = simd_quatf(angle: radians(90), axis: [1, 0, 0])
        addChild(spriteEntity)

//        let hpEntity = try await Entity.loadHP()
//        hpEntity.position = [0, -1, 0.5]
//        addChild(hpEntity)
    }

    convenience init(from mapItem: MapItem, resourceManager: ResourceManager) async throws {
        self.init()

        let scriptContext = await resourceManager.scriptContext()
        if let path = ResourcePath.generateItemSpritePath(itemID: Int(mapItem.itemID), scriptContext: scriptContext) {
            let sprite = try await resourceManager.sprite(at: path)
            let animation = try await SpriteAnimation(sprite: sprite, actionIndex: 0)

            let spriteEntity = SpriteEntity(animation: animation)
            spriteEntity.name = "sprite"
            spriteEntity.orientation = simd_quatf(angle: radians(90), axis: [1, 0, 0])
            addChild(spriteEntity)
        }
    }
}

extension Entity {
    func playSpriteAnimation(
        _ actionType: CharacterActionType,
        direction: CharacterDirection,
        repeats: Bool,
        actionEnded: (() -> Void)? = nil
    ) {
        guard let spriteEntity = findEntity(named: "sprite"),
              let animations = spriteEntity.components[SpriteAnimationsComponent.self]?.animations else {
            return
        }

        spriteEntity.components.set(
            SpriteActionComponent(actionType: actionType, direction: direction, headDirection: .lookForward)
        )

        let animationName = SpriteAnimation.animationName(
            for: actionType,
            direction: direction,
            headDirection: .lookForward
        )
        guard let animation = animations[animationName] else {
            return
        }

        spriteEntity.stopAllAnimations()

        spriteEntity.position = [
            -animation.pivot.x / 32,
            -(animation.frameHeight / 2 - animation.pivot.y) / 32,
            animation.frameHeight / 2 / 32 * spriteEntity.scale.y,
        ]

        do {
            let duration = (repeats ? .infinity : animation.duration)
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration, actionEnded: actionEnded)
            spriteEntity.playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error)")
        }
    }

    func playDefaultSpriteAnimation(repeats: Bool) {
        guard let spriteEntity = findEntity(named: "sprite"),
              let animation = spriteEntity.components[SpriteAnimationsComponent.self]?.defaultAnimation else {
            return
        }

        spriteEntity.stopAllAnimations()

        spriteEntity.position = [
            -animation.pivot.x / 32,
            -(animation.frameHeight / 2 - animation.pivot.y) / 32,
            animation.frameHeight / 2 / 32 * spriteEntity.scale.y,
        ]

        do {
            let duration = (repeats ? .infinity : animation.duration)
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration, actionEnded: nil)
            spriteEntity.playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error)")
        }
    }

    @available(*, deprecated)
    func walk(through path: [SIMD2<Int>], mapGrid: MapGrid) {
        guard let spriteEntity = findEntity(named: "sprite") else {
            return
        }

        guard let mapObject = components[MapObjectComponent.self]?.mapObject,
              let animations = spriteEntity.components[SpriteAnimationsComponent.self]?.animations else {
            return
        }

        spriteEntity.stopAllAnimations()

        do {
            var animationSequence: [AnimationResource] = []
            for i in 1..<path.count {
                let sourcePosition = path[i - 1]
                let targetPosition = path[i]

                let direction: CharacterDirection = switch (targetPosition &- sourcePosition) {
                case [0, -1]:
                    .south
                case [-1, -1]:
                    .southwest
                case [-1, 0]:
                    .west
                case [-1, 1]:
                    .northwest
                case [0, 1]:
                    .north
                case [1, 1]:
                    .northeast
                case [1, 0]:
                    .east
                case [1, -1]:
                    .southeast
                default:
                    .south
                }

                let speed = TimeInterval(mapObject.speed) / 1000
                let duration = direction.isDiagonal ? speed * sqrt(2) : speed

                let animationName = SpriteAnimation.animationName(
                    for: .walk,
                    direction: direction,
                    headDirection: .lookForward
                )
                guard let animation = animations[animationName] else {
                    continue
                }

                let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration) {
                    self.components[GridPositionComponent.self]?.gridPosition = targetPosition
                    if i == path.count - 1 {
                        self.playSpriteAnimation(.idle, direction: direction, repeats: true)
                    }
                }

                let sourceAltitude = mapGrid[sourcePosition].averageAltitude
                let targetAltitude = mapGrid[targetPosition].averageAltitude

                var sourceTransform = transform
                sourceTransform.translation = [
                    Float(sourcePosition.x) + 0.5 - animation.pivot.x / 32,
                    Float(sourcePosition.y) + 0.5 - (animation.frameHeight / 2 - animation.pivot.y) / 32,
                    sourceAltitude + animation.frameHeight / 2 / 32 * spriteEntity.scale.y,
                ]

                var targetTransform = transform
                targetTransform.translation = [
                    Float(targetPosition.x) + 0.5 - animation.pivot.x / 32,
                    Float(targetPosition.y) + 0.5 - (animation.frameHeight / 2 - animation.pivot.y) / 32,
                    targetAltitude + animation.frameHeight / 2 / 32 * spriteEntity.scale.y,
                ]

                let moveAction = FromToByAction(from: sourceTransform, to: targetTransform, mode: .parent, timing: .linear)
                let moveAnimation = try AnimationResource.makeActionAnimation(for: moveAction, duration: duration, bindTarget: .transform)

                let groupAnimation = try AnimationResource.group(with: [actionAnimation, moveAnimation])
                animationSequence.append(groupAnimation)
            }

            let animationResource = try AnimationResource.sequence(with: animationSequence)
            spriteEntity.playAnimation(animationResource)
        } catch {
            logger.warning("\(error)")
        }
    }

    func attack(direction: CharacterDirection) {
        guard let mapObject = components[MapObjectComponent.self]?.mapObject else {
            return
        }

        let attackActionType = CharacterActionType.attackActionType(
            forJobID: mapObject.job,
            gender: mapObject.gender,
            weapon: mapObject.weapon
        )

        playSpriteAnimation(attackActionType, direction: direction, repeats: false) {
            self.playSpriteAnimation(.readyToAttack, direction: direction, repeats: true)
        }
    }
}

extension Entity {
    func generateModelAndCollisionShape(for animation: SpriteAnimation) {
        let width = animation.frameWidth / 32
        let height = animation.frameHeight / 32

        // Create material.
        var material = PhysicallyBasedMaterial()
        material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.7)
        material.opacityThreshold = 0.0001
        material.blending = .transparent(opacity: 1.0)

        if let texture = animation.texture {
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.textureCoordinateTransform = MaterialParameterTypes.TextureCoordinateTransform(scale: [1 / Float(animation.frameCount), 1])
        }

        // Create model component.
        let modelComponent = ModelComponent(
            mesh: .generatePlane(width: width, height: height),
            materials: [material]
        )
        components.set(modelComponent)

        // Create collision component.
        let collisionComponent = CollisionComponent(
            shapes: [.generateBox(width: width, height: height, depth: 0)]
        )
        components.set(collisionComponent)
    }
}

extension AnimationResource {
    @available(*, deprecated)
    static func generate(with animation: SpriteAnimation, repeats: Bool, trimDuration: TimeInterval? = nil) throws -> AnimationResource {
        var frames: [SIMD2<Float>] = (0..<animation.frameCount).map { frameIndex in
            [Float(frameIndex) / Float(animation.frameCount), 0]
        }
        if repeats {
            frames = Array(repeating: frames, count: 100).flatMap({ $0 })
        }
        let animationDefinition = SampledAnimation(
            frames: frames,
            name: "action",
            tweenMode: .hold,
            frameInterval: Float(animation.frameInterval),
            isAdditive: false,
            bindTarget: .material(0).textureCoordinate.offset,
            repeatMode: repeats ? .repeat : .none,
            trimDuration: trimDuration
        )
        let animationResource = try AnimationResource.generate(with: animationDefinition)
        return animationResource
    }

    static func makeActionAnimation(with animation: SpriteAnimation, duration: TimeInterval, actionEnded: (() -> Void)?) throws -> AnimationResource {
        let action = PlaySpriteAnimationAction(animation: animation, actionEnded: actionEnded)
        let actionAnimation = try makeActionAnimation(for: action, duration: duration)
        return actionAnimation
    }
}
