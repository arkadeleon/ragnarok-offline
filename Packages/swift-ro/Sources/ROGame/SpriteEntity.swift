//
//  SpriteEntity.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/22.
//

import RealityKit
import RORendering

public class SpriteEntity: Entity {
    public required init() {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)
    }

    public init(jobID: UniformJobID, configuration: SpriteConfiguration) async throws {
        super.init()

        let inputTargetComponent = InputTargetComponent()
        components.set(inputTargetComponent)

        let actions = try await SpriteAction.actions(for: jobID, configuration: configuration)
        let spriteComponent = SpriteComponent(actions: actions)
        components.set(spriteComponent)
    }

    public func runPlayerAction(_ actionType: PlayerActionType, direction: BodyDirection) {
        let actionIndex = actionType.rawValue * 8 + direction.rawValue
        runAction(actionIndex)
    }

    public func runAction(_ actionIndex: Int) {
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

        let frames: [SIMD2<Float>] = (0..<action.frameCount).map { frameIndex in
            [Float(frameIndex) / Float(action.frameCount), 0]
        }
        let bindTarget = BindTarget.material(0).textureCoordinate.offset
        let animationDefinition = SampledAnimation(
            frames: Array(repeating: frames, count: 100).flatMap({ $0 }),
            name: "action",
            tweenMode: .hold,
            frameInterval: action.frameInterval,
            isAdditive: false,
            bindTarget: bindTarget,
            repeatMode: .repeat
        )

        if let animation = try? AnimationResource.generate(with: animationDefinition) {
            playAnimation(animation)
        }
    }
}
