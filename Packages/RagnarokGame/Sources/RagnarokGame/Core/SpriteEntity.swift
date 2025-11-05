//
//  SpriteEntity.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/2/22.
//

import Foundation
import RagnarokSprite
import RealityKit

class SpriteEntity: Entity {
    convenience required init() {
        self.init(animations: [:])
    }

    convenience init(animation: SpriteAnimation) {
        self.init(animations: ["default": animation])
    }

    init(animations: [String : SpriteAnimation]) {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)

        let hoverEffectComponent = HoverEffectComponent(.highlight(.default))
        components.set(hoverEffectComponent)

        let shadowComponent = DynamicLightShadowComponent(castsShadow: false)
        components.set(shadowComponent)

        let spriteComponent = SpriteComponent(animations: animations)
        components.set(spriteComponent)
    }

    func playSpriteAnimation(
        _ actionType: CharacterActionType,
        direction: CharacterDirection,
        repeats: Bool,
        actionEnded: (() -> Void)? = nil
    ) {
        guard let mapGrid = components[MapGridComponent.self]?.mapGrid,
              let animations = components[SpriteComponent.self]?.animations else {
            return
        }

        let animationName = SpriteAnimation.animationName(
            for: actionType,
            direction: direction,
            headDirection: .lookForward
        )
        guard let animation = animations[animationName] else {
            return
        }

        stopAllAnimations()

        let gridPosition = gridPosition
        let altitude = mapGrid[gridPosition].averageAltitude

        self.position = [
            Float(gridPosition.x) + 0.5 - animation.pivot.x / 32,
            Float(gridPosition.y) + 0.5 - (animation.frameHeight / 2 - animation.pivot.y) / 32,
            altitude + animation.frameHeight / 2 / 32 * scale.y,
        ]

        do {
            let duration = (repeats ? .infinity : animation.duration)
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration, actionEnded: actionEnded)
            playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error)")
        }
    }

    func playDefaultSpriteAnimation(repeats: Bool) {
        guard let mapGrid = components[MapGridComponent.self]?.mapGrid,
              let animations = components[SpriteComponent.self]?.animations,
              let animation = animations.values.first else {
            return
        }

        stopAllAnimations()

        let gridPosition = gridPosition
        let altitude = mapGrid[gridPosition].averageAltitude

        self.position = [
            Float(gridPosition.x) + 0.5 - animation.pivot.x / 32,
            Float(gridPosition.y) + 0.5 - (animation.frameHeight / 2 - animation.pivot.y) / 32,
            altitude + animation.frameHeight / 2 / 32 * scale.y,
        ]

        do {
            let duration = (repeats ? .infinity : animation.duration)
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration, actionEnded: nil)
            playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error)")
        }
    }

    @available(*, deprecated)
    func walk(through path: [SIMD2<Int>]) {
        guard let mapGrid = components[MapGridComponent.self]?.mapGrid,
              let mapObject = components[MapObjectComponent.self]?.mapObject,
              let animations = components[SpriteComponent.self]?.animations else {
            return
        }

        stopAllAnimations()

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
                    sourceAltitude + animation.frameHeight / 2 / 32 * scale.y,
                ]

                var targetTransform = transform
                targetTransform.translation = [
                    Float(targetPosition.x) + 0.5 - animation.pivot.x / 32,
                    Float(targetPosition.y) + 0.5 - (animation.frameHeight / 2 - animation.pivot.y) / 32,
                    targetAltitude + animation.frameHeight / 2 / 32 * scale.y,
                ]

                let moveAction = FromToByAction(from: sourceTransform, to: targetTransform, mode: .parent, timing: .linear)
                let moveAnimation = try AnimationResource.makeActionAnimation(for: moveAction, duration: duration, bindTarget: .transform)

                let groupAnimation = try AnimationResource.group(with: [actionAnimation, moveAnimation])
                animationSequence.append(groupAnimation)
            }

            let animationResource = try AnimationResource.sequence(with: animationSequence)
            playAnimation(animationResource)
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

    @available(*, deprecated)
    private func generateModelForAnimation(named animationName: String) {
        guard let animations = components[SpriteComponent.self]?.animations,
              let animation = animations[animationName] else {
            return
        }

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
