/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The component and system for moving an entity toward another entity.
*/

import RealityKit

/// A component that tells an entity to move toward another entity.
public struct FollowComponent: Component {
    var smoothing: SIMD3<Float> = .one * 0.5
    let targetId: Entity.ID
    public var targetOverride: Entity.ID?
    public init(targetId: Entity.ID, smoothing: SIMD3<Float> = .one * 3) {
        self.targetId = targetId
        self.smoothing = smoothing
        Task {
            await FollowSystem.registerSystem()
        }
    }

    internal var currentTarget: Entity.ID { targetOverride ?? targetId }
}

/// A system that moves entities that have a follow component.
struct FollowSystem: System {
    init(scene: Scene) {}

    @MainActor
    static let query = EntityQuery(where: .has(FollowComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let component = entity.components[FollowComponent.self],
                  let target = context.scene.findEntity(id: component.currentTarget)
            else { continue }

            let targetPosition = target.position(relativeTo: entity.parent)
            entity.position = mix(entity.position, targetPosition,
                                  t: component.smoothing * Float(context.deltaTime))
        }
    }
}
