/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Implements a RealityKit system for world cameras.
*/

import RealityKit

/// A system that updates the world origin of a space based on
/// the world camera component.
struct WorldCameraSystem: System {
    let scene: Scene

    init(scene: Scene) {
        self.scene = scene
    }

    /// Looks through an entity and its ancestors, and returns the first one that has
    /// a world component, a physics simulation component, or the highest root entity in the tree.
    @MainActor
    internal func findRootEntity(in entity: Entity) -> Entity {
        if !entity.components.has(WorldComponent.self),
           !entity.components.has(PhysicsSimulationComponent.self),
           let parent = entity.parent {
            findRootEntity(in: parent)
        } else { entity }
    }

    func calculateCameraPositionFromTarget(
        targetTransform: Transform,
        radius: Float,
        targetOffset: SIMD3<Float>
    ) -> (position: SIMD3<Float>, orientation: simd_quatf) {
        // Extract the camera's orientation from the inverse of the target's transform rotation.
        let cameraOrientation = targetTransform.rotation.inverse

        // Extract the target (focus) position from the target transform.
        let targetPosition = targetTransform.translation

        // Calculate the camera's forward direction in world space (negative z-axis).
        let forwardDirection = cameraOrientation.act(SIMD3<Float>(0, 0, -1))

        // Calculate the camera's position by moving backward from the target position along the forward direction.
        let cameraPosition = targetPosition - forwardDirection * (radius + simd_length(targetOffset))

        return (cameraPosition, cameraOrientation)
    }

    public mutating func update(context: SceneUpdateContext) {
        let trackingTargets = context.entities(
            matching: EntityQuery(where: .has(WorldCameraComponent.self)),
            updatingSystemWhen: .rendering
        )
        guard let trackingCamera = trackingTargets.first(where: { _ in true }),
              var cameraComponent = trackingCamera.components[WorldCameraComponent.self]
        else { return }

        if simd_length(cameraComponent.continuousMotion) > 0 {
            cameraComponent.updateWith(joystickMotion: cameraComponent.continuousMotion)
        }

        let worldParent: Entity
        if let worldParentId = cameraComponent.worldParentId,
           let foundParent = scene.findEntity(id: worldParentId) {
            worldParent = foundParent
        } else {
            worldParent = findRootEntity(in: trackingCamera)
            trackingCamera.components[WorldCameraComponent.self]?.worldParentId = worldParent.id
        }

        // Calculate camera orientation and position based on the target.
        let cameraOrientation = cameraComponent.cameraAxisOrientation()
        let exactCameraPosition = cameraOrientation.act([0, 0, cameraComponent.radius] + cameraComponent.targetOffset)
        let exactCameraTransform = trackingCamera.convert(
            transform: Transform(rotation: cameraOrientation, translation: exactCameraPosition),
            to: worldParent
        )

        var targetTransform = Transform(matrix: exactCameraTransform.matrix.inverse)

        // MARK: Follow mode logic

        switch cameraComponent.followMode {
        case .exact:
            // Exact follow: Use the exact position and orientation as calculated above.
            targetTransform = Transform(matrix: exactCameraTransform.matrix.inverse)
        }

        // MARK: Follow movement logic
        if cameraComponent.isRealityKitCamera {
            trackingCamera.children.first(where: { child in
                child.components.has(PerspectiveCameraComponent.self) ||
                child.components.has(OrthographicCameraComponent.self) ||
                child.components.has(ProjectiveTransformCameraComponent.self)
            })?.transform = Transform(rotation: cameraOrientation, translation: exactCameraPosition)
        } else {
            switch cameraComponent.movementStyle {
            case .instantaneous:
                worldParent.transform = targetTransform
            case let .smooth(decayFactor):
                worldParent.transform = worldParent.transform.moveTowards(
                    targetTransform, decayFactor: decayFactor * Float(context.deltaTime))
            }
        }
        trackingCamera.components.set(cameraComponent)
    }
}

fileprivate extension Transform {
    func moveTowards(
        _ targetTransform: Transform,
        decayFactor: Float
    ) -> Transform {
        let rotation = simd_slerp(rotation, targetTransform.rotation, decayFactor)
        let translation = mix(translation, targetTransform.translation, t: decayFactor)
        return Transform(rotation: rotation, translation: translation)
    }
}
