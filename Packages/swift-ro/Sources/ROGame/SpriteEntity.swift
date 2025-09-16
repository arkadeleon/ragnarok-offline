//
//  SpriteEntity.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/22.
//

import Foundation
import RealityKit
import SpriteRendering

class SpriteEntity: Entity {
    static let pivot: SIMD3<Float> = [0.5, 2, 0]

    required init() {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)
    }

    init(animations: [SpriteAnimation]) {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)

        let spriteComponent = SpriteComponent(animations: animations)
        components.set(spriteComponent)
    }

    func playSpriteAnimation(_ actionType: ComposedSprite.ActionType, direction: ComposedSprite.Direction, repeats: Bool) {
        guard let mapObject = components[MapObjectComponent.self]?.mapObject,
              let animations = components[SpriteComponent.self]?.animations else {
            return
        }

        let animationIndex = actionType.calculateActionIndex(forJobID: mapObject.job, direction: direction)
        guard animationIndex < animations.count else {
            return
        }

        stopAllAnimations()

        do {
            let animation = animations[animationIndex]
            let duration = (repeats ? .infinity : animation.duration)
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration, actionEnded: nil)
            playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }

    func playSpriteAnimation(at animationIndex: Int, repeats: Bool) {
        guard let animations = components[SpriteComponent.self]?.animations,
              animationIndex < animations.count else {
            return
        }

        stopAllAnimations()

        do {
            let animation = animations[animationIndex]
            let duration = (repeats ? .infinity : animation.duration)
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration, actionEnded: nil)
            playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }

    func walk(through path: [(position: SIMD2<Int>, altitude: Float)], scale: SIMD3<Float>) {
        guard let mapObject = components[MapObjectComponent.self]?.mapObject,
              let animations = components[SpriteComponent.self]?.animations else {
            return
        }

        stopAllAnimations()

        do {
            let speed = TimeInterval(mapObject.speed) / 1000

            var animationSequence: [AnimationResource] = []
            for i in 1..<path.count {
                let sourcePosition = path[i - 1].position
                let targetPosition = path[i].position

                let direction: ComposedSprite.Direction
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

                let animationIndex = ComposedSprite.ActionType.walk.calculateActionIndex(forJobID: mapObject.job, direction: direction)
                let animation = animations[animationIndex]
                let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration) {
                    self.components[MapObjectComponent.self]?.position = targetPosition
                }

                let sourceAltitude = path[i - 1].altitude
                let targetAltitude = path[i].altitude

                let sourceTransform = Transform(
                    scale: scale,
                    translation: [
                        Float(sourcePosition.x),
                        -sourceAltitude / 5,
                        -Float(sourcePosition.y)
                    ] + SpriteEntity.pivot
                )

                let targetTransform = Transform(
                    scale: scale,
                    translation: [
                        Float(targetPosition.x),
                        -targetAltitude / 5,
                        -Float(targetPosition.y)
                    ] + SpriteEntity.pivot
                )

                let moveAction = FromToByAction(from: sourceTransform, to: targetTransform, mode: .parent, timing: .linear)
                let moveAnimation = try AnimationResource.makeActionAnimation(for: moveAction, duration: duration, bindTarget: .transform)

                let groupAnimation = try AnimationResource.group(with: [actionAnimation, moveAnimation])
                animationSequence.append(groupAnimation)
            }

            let animationResource = try AnimationResource.sequence(with: animationSequence)
            playAnimation(animationResource)
        } catch {
            logger.warning("\(error.localizedDescription)")
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
