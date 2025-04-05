//
//  SpriteEntity.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/22.
//

import Foundation
import RealityKit
import RORendering

enum SpriteAnimationError: Error {
    case actionIndexOutOfRange
}

public class SpriteEntity: Entity {
    public required init() {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)
    }

    public init(actions: [SpriteAction]) {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)

        let spriteComponent = SpriteComponent(actions: actions)
        components.set(spriteComponent)
    }

    public func runPlayerAction(_ actionType: PlayerActionType, direction: BodyDirection, repeats: Bool) {
        let actionIndex = actionType.rawValue * 8 + direction.rawValue

        generateModel(forActionAt: actionIndex)

        do {
            let animation = try generateAnimation(forActionAt: actionIndex, repeats: repeats)
            stopAllAnimations()
            playAnimation(animation)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }

    public func runAction(_ actionIndex: Int, repeats: Bool) {
        generateModel(forActionAt: actionIndex)

        do {
            let animation = try generateAnimation(forActionAt: actionIndex, repeats: repeats)
            stopAllAnimations()
            playAnimation(animation)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }

    public func walk(to target: Transform, direction: BodyDirection, duration: TimeInterval) {
        let actionIndex = PlayerActionType.walk.rawValue * 8 + direction.rawValue

        generateModel(forActionAt: actionIndex)

        do {
            let walkAnimation = try generateWalkAnimation(withTarget: target, direction: direction, duration: duration)
            stopAllAnimations()
            playAnimation(walkAnimation)
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }

    private func generateModel(forActionAt actionIndex: Int) {
        guard let spriteComponent = components[SpriteComponent.self],
              actionIndex < spriteComponent.actions.count else {
            return
        }

        let action = spriteComponent.actions[actionIndex]

        let width = action.frameWidth / 32
        let height = action.frameHeight / 32

        // Create material.
        var material = PhysicallyBasedMaterial()
        material.blending = .transparent(opacity: 1.0)
        material.opacityThreshold = 0.0001

        if let texture = action.texture {
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.textureCoordinateTransform = PhysicallyBasedMaterial.TextureCoordinateTransform(scale: [1 / Float(action.frameCount), 1])
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

    private func generateAnimation(forActionAt actionIndex: Int, repeats: Bool, trimDuration: TimeInterval? = nil) throws -> AnimationResource {
        guard let spriteComponent = components[SpriteComponent.self],
              actionIndex < spriteComponent.actions.count else {
            throw SpriteAnimationError.actionIndexOutOfRange
        }

        let action = spriteComponent.actions[actionIndex]

        let spriteAnimation = try AnimationResource.generateSpriteAnimation(for: action, repeats: repeats, trimDuration: trimDuration)
        return spriteAnimation
    }

    private func generateWalkAnimation(withTarget target: Transform, direction: BodyDirection, duration: TimeInterval) throws -> AnimationResource {
        let actionIndex = PlayerActionType.walk.rawValue * 8 + direction.rawValue
        let spriteAnimation = try generateAnimation(forActionAt: actionIndex, repeats: true, trimDuration: duration)

        let moveAction = FromToByAction(to: target, timing: .linear)
        let moveAnimation = try AnimationResource.makeActionAnimation(for: moveAction, duration: duration, bindTarget: .transform)

        let animation = try AnimationResource.group(with: [spriteAnimation, moveAnimation])
        return animation
    }
}

extension AnimationResource {
    static func generateSpriteAnimation(for action: SpriteAction, repeats: Bool, trimDuration: TimeInterval? = nil) throws -> AnimationResource {
        var frames: [SIMD2<Float>] = (0..<action.frameCount).map { frameIndex in
            [Float(frameIndex) / Float(action.frameCount), 0]
        }
        if repeats {
            frames = Array(repeating: frames, count: 100).flatMap({ $0 })
        }
        let animationDefinition = SampledAnimation(
            frames: frames,
            name: "action",
            tweenMode: .hold,
            frameInterval: action.frameInterval,
            isAdditive: false,
            bindTarget: .material(0).textureCoordinate.offset,
            repeatMode: repeats ? .repeat : .none,
            trimDuration: trimDuration
        )
        let animation = try AnimationResource.generate(with: animationDefinition)
        return animation
    }
}
