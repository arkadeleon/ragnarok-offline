//
//  PlaySpriteAnimationAction.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/6/25.
//

import Foundation
import RealityKit

@MainActor
struct PlaySpriteAnimationAction: @preconcurrency EntityAction {
    let animation: SpriteAnimation
    let actionEnded: (() -> Void)?

    var animatedValueType: (any AnimatableData.Type)? {
        nil
    }
}

@MainActor
struct PlaySpriteAnimationActionHandler: @preconcurrency ActionHandlerProtocol {
    typealias ActionType = PlaySpriteAnimationAction

    func actionStarted(event: EventType) {
        guard let entity = event.playbackController.entity else {
            return
        }

        let animation = event.action.animation
        entity.generateModelAndCollisionShape(for: animation)
    }

    func actionUpdated(event: EventType) {
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

    func actionEnded(event: EventType) {
        event.action.actionEnded?()
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
