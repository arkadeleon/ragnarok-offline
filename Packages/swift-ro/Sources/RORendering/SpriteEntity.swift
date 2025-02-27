//
//  SpriteEntity.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/22.
//

import RealityKit

public class SpriteEntity: Entity {
    public required init() {
        super.init()
    }

    public init(jobID: UniformJobID, configuration: SpriteConfiguration) async throws {
        super.init()

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

        // Create mesh.
        let mesh = MeshResource.generatePlane(
            width: Float(action.frameWidth) / 32,
            height: Float(action.frameHeight) / 32
        )

        // Create material.
        var material = PhysicallyBasedMaterial()
        material.blending = .transparent(opacity: 1.0)
        material.opacityThreshold = 0.9999

        if let texture = action.texture {
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.textureCoordinateTransform = PhysicallyBasedMaterial.TextureCoordinateTransform(scale: [1 / Float(action.frameCount), 1])
        }

        // Create model component.
        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        components.set(modelComponent)

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
