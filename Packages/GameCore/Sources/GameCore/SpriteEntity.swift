//
//  SpriteEntity.swift
//  GameCore
//
//  Created by Leon Li on 2025/2/22.
//

import Foundation
import RealityKit
import SpriteRendering

class SpriteEntity: Entity {
    required init() {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)

        let shadowComponent = DynamicLightShadowComponent(castsShadow: false)
        components.set(shadowComponent)
    }

    init(animations: [SpriteAnimation]) {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)

        let shadowComponent = DynamicLightShadowComponent(castsShadow: false)
        components.set(shadowComponent)

        let spriteComponent = SpriteComponent(animations: animations)
        components.set(spriteComponent)
    }

    func playSpriteAnimation(_ actionType: CharacterActionType, direction: CharacterDirection, repeats: Bool) {
        guard let gridPosition = components[GridPositionComponent.self]?.gridPosition,
              let mapGrid = components[MapGridComponent.self]?.mapGrid,
              let mapObject = components[MapObjectComponent.self]?.mapObject,
              let animations = components[SpriteComponent.self]?.animations else {
            return
        }

        let animationIndex = actionType.calculateActionIndex(forJobID: mapObject.job, direction: direction)
        guard animationIndex < animations.count else {
            return
        }

        stopAllAnimations()

        let animation = animations[animationIndex]
        let altitude = mapGrid[gridPosition].altitude

        self.position = [
            Float(gridPosition.x) + 0.5 - animation.pivot.x / 32,
            -altitude / 5 + animation.frameHeight / 2 / 32 * scale.y,
            -Float(gridPosition.y) - 0.5 + (animation.frameHeight / 2 - animation.pivot.y) / 32
        ]

        do {
            let duration = (repeats ? .infinity : animation.duration)
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration, actionEnded: nil)
            playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error)")
        }
    }

    func playSpriteAnimation(at animationIndex: Int, repeats: Bool) {
        guard let gridPosition = components[GridPositionComponent.self]?.gridPosition,
              let mapGrid = components[MapGridComponent.self]?.mapGrid,
              let animations = components[SpriteComponent.self]?.animations,
              animationIndex < animations.count else {
            return
        }

        stopAllAnimations()

        let animation = animations[animationIndex]
        let altitude = mapGrid[gridPosition].altitude

        self.position = [
            Float(gridPosition.x) + 0.5 - animation.pivot.x / 32,
            -altitude / 5 + animation.frameHeight / 2 / 32 * scale.y,
            -Float(gridPosition.y) - 0.5 + (animation.frameHeight / 2 - animation.pivot.y) / 32
        ]

        do {
            let duration = (repeats ? .infinity : animation.duration)
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration, actionEnded: nil)
            playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error)")
        }
    }

    func walk(through path: [SIMD2<Int>]) {
        guard let mapGrid = components[MapGridComponent.self]?.mapGrid,
              let mapObject = components[MapObjectComponent.self]?.mapObject,
              let animations = components[SpriteComponent.self]?.animations else {
            return
        }

        stopAllAnimations()

        do {
            let speed = TimeInterval(mapObject.speed) / 1000

            var animationSequence: [AnimationResource] = []
            for i in 1..<path.count {
                let sourcePosition = path[i - 1]
                let targetPosition = path[i]

                let direction: CharacterDirection
                let duration: TimeInterval
                switch (targetPosition &- sourcePosition) {
                case [-1, -1]:
                    direction = .southwest
                    duration = speed * sqrt(2)
                case [-1, 0]:
                    direction = .west
                    duration = speed
                case [-1, 1]:
                    direction = .northwest
                    duration = speed * sqrt(2)
                case [0, 1]:
                    direction = .north
                    duration = speed
                case [1, 1]:
                    direction = .northeast
                    duration = speed * sqrt(2)
                case [1, 0]:
                    direction = .east
                    duration = speed
                case [1, -1]:
                    direction = .southeast
                    duration = speed * sqrt(2)
                default:
                    direction = .south
                    duration = speed
                }

                let animationIndex = CharacterActionType.walk.calculateActionIndex(forJobID: mapObject.job, direction: direction)
                let animation = animations[animationIndex]
                let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration) {
                    self.components[GridPositionComponent.self]?.gridPosition = targetPosition
                    if i == path.count - 1 {
                        self.playSpriteAnimation(.idle, direction: direction, repeats: true)
                    }
                }

                let sourceAltitude = mapGrid[sourcePosition].altitude
                let targetAltitude = mapGrid[targetPosition].altitude

                var sourceTransform = transform
                sourceTransform.translation = [
                    Float(sourcePosition.x) + 0.5 - animation.pivot.x / 32,
                    -sourceAltitude / 5 + animation.frameHeight / 2 / 32 * scale.y,
                    -Float(sourcePosition.y) - 0.5 + (animation.frameHeight / 2 - animation.pivot.y) / 32
                ]

                var targetTransform = transform
                targetTransform.translation = [
                    Float(targetPosition.x) + 0.5 - animation.pivot.x / 32,
                    -targetAltitude / 5 + animation.frameHeight / 2 / 32 * scale.y,
                    -Float(targetPosition.y) - 0.5 + (animation.frameHeight / 2 - animation.pivot.y) / 32
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

    @available(*, deprecated)
    private func generateModelForAnimation(at animationIndex: Int) {
        guard let animations = components[SpriteComponent.self]?.animations,
              animationIndex < animations.count else {
            return
        }

        let animation = animations[animationIndex]

        let width = animation.frameWidth / 32
        let height = animation.frameHeight / 32

        // Create material.
        var material = PhysicallyBasedMaterial()
        material.blending = .transparent(opacity: 1.0)
        material.opacityThreshold = 0.0001

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
