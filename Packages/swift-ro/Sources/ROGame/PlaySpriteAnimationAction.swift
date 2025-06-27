//
//  PlaySpriteAnimationAction.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/25.
//

import Foundation
import RealityKit

public struct PlaySpriteAnimationAction: EntityAction {
    public let animation: SpriteAnimation

    public var animatedValueType: (any AnimatableData.Type)? {
        nil
    }

    public init(animation: SpriteAnimation) {
        self.animation = animation
    }
}

@MainActor
public struct PlaySpriteAnimationActionHandler: @preconcurrency ActionHandlerProtocol {
    public typealias ActionType = PlaySpriteAnimationAction

    public init() {
    }

    public func actionStarted(event: EventType) {
        guard let entity = event.playbackController.entity else {
            return
        }

        let animation = event.action.animation

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
        entity.components.set(modelComponent)

        // Create collision component.
        let collisionComponent = CollisionComponent(
            shapes: [.generateBox(width: width, height: height, depth: 0)]
        )
        entity.components.set(collisionComponent)
    }

    public func actionUpdated(event: EventType) {
        guard let entity = event.playbackController.entity else {
            return
        }

        let animation = event.action.animation

        let frameIndex = Int(event.playbackController.time / animation.frameInterval) % animation.frameCount

        if let _ = animation.texture {
            entity.components[ModelComponent.self]?.materialTextureCoordinateTransform = MaterialParameterTypes.TextureCoordinateTransform(
                offset: [Float(frameIndex) / Float(animation.frameCount), 0],
                scale: [1 / Float(animation.frameCount), 1]
            )
        }
    }
}

extension ModelComponent {
    var materialTextureCoordinateTransform: MaterialParameterTypes.TextureCoordinateTransform? {
        get {
            let material = materials[0] as? PhysicallyBasedMaterial
            return material?.textureCoordinateTransform
        }
        set {
            if let newValue, var material = materials[0] as? PhysicallyBasedMaterial {
                material.textureCoordinateTransform = newValue
                materials[0] = material
            }
        }
    }
}
