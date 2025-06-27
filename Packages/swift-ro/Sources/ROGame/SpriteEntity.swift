//
//  SpriteEntity.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/22.
//

import Foundation
import RealityKit
import RORendering

public class SpriteEntity: Entity {
    public required init() {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)
    }

    public init(animations: [SpriteAnimation]) {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)

        let spriteComponent = SpriteComponent(animations: animations)
        components.set(spriteComponent)
    }

    public func playSpriteAnimation(_ actionType: ComposedSprite.ActionType, direction: ComposedSprite.Direction, repeats: Bool) {
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
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration)
            playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }

    public func playSpriteAnimation(at animationIndex: Int, repeats: Bool) {
        guard let animations = components[SpriteComponent.self]?.animations,
              animationIndex < animations.count else {
            return
        }

        stopAllAnimations()

        do {
            let animation = animations[animationIndex]
            let duration = (repeats ? .infinity : animation.duration)
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration)
            playAnimation(actionAnimation)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }

    public func walk(to target: Transform, direction: ComposedSprite.Direction, duration: TimeInterval) {
        guard let mapObject = components[MapObjectComponent.self]?.mapObject,
              let animations = components[SpriteComponent.self]?.animations else {
            return
        }

        let animationIndex = ComposedSprite.ActionType.walk.calculateActionIndex(forJobID: mapObject.job, direction: direction)
        guard animationIndex < animations.count else {
            return
        }

        stopAllAnimations()

        do {
            let animation = animations[animationIndex]
            let actionAnimation = try AnimationResource.makeActionAnimation(with: animation, duration: duration)

            let moveAction = FromToByAction(to: target, timing: .linear)
            let moveAnimation = try AnimationResource.makeActionAnimation(for: moveAction, duration: duration, bindTarget: .transform)

            let animationResource = try AnimationResource.group(with: [actionAnimation, moveAnimation])
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

    static func makeActionAnimation(with animation: SpriteAnimation, duration: TimeInterval) throws -> AnimationResource {
        let action = PlaySpriteAnimationAction(animation: animation)
        let actionAnimation = try makeActionAnimation(for: action, duration: duration)
        return actionAnimation
    }
}
