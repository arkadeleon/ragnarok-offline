/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Implements a RealityKit component for cameras in a space.
*/

import Foundation
import RealityKit

/// A component that represents a camera in a space that orients around a spherical area.
///
/// Choose an entity as your target in a scene, and add this component to it as such:
///
/// ```swift
/// // The target entity, which might be, for example, a character in a game.
/// let character = Entity(named: "fenton")
///
/// // ...
///
/// // Set the component on the character entity.
/// character.components.set(WorldCameraComponent())
/// ```
///
/// To choose the angle at which the camera looks at the target entity, update the `azimuth`, `elevation`, `radius`, or `targetOffset` values.
///
/// ```swift
/// var cameraComponent = WorldCameraComponent(
///     azimuth: .pi,
///     elevation: 0,
///     radius: 2,
/// )
/// cameraComponent.targetOffset = [0, -0.75, 0]
/// ```
///
/// You can set these values at any time, and the world camera system keeps the scene orientation up to date.
public struct WorldCameraComponent: Component {

    /// The horizontal angle or direction of the camera from its center target.
    public var azimuth: Float

    /// The vertical angle of the camera from its center target.
    public var elevation: Float

    /// The distance of the camera from its center target.
    public var radius: Float

    public var targetOffset: SIMD3<Float> = .zero

    /// The containing scene that the system for this component moves.
    internal var worldParentId: Entity.ID?

    public internal(set) var continuousMotion: SIMD2<Float> = .zero

    public internal(set) var cameraVelocity: (linear: SIMD3<Float>, angular: SIMD3<Float>) = (.zero, .zero)

    public enum CameraFollowMode {
        case exact
    }

    public var followMode: CameraFollowMode = .exact

    public enum CameraMovementStyle {
        case instantaneous
        case smooth(Float) // recommend 3
    }

    #if os(visionOS)
    public var isRealityKitCamera: Bool = false
    #else
    public var isRealityKitCamera: Bool = true
    #endif

    public var movementStyle: CameraMovementStyle = .instantaneous // .smooth(3)

    public struct CameraBounds {
        var azimuth: ClosedRange<Float>?
        var elevation: ClosedRange<Float>?
        var radius: ClosedRange<Float>?

        public init(
            azimuth: ClosedRange<Float>? = nil,
            elevation: ClosedRange<Float>? = nil,
            radius: ClosedRange<Float>? = nil
        ) {
            self.azimuth = azimuth
            self.elevation = elevation
            self.radius = radius
        }
    }

    public var bounds: CameraBounds?

    public init(azimuth: Float = 0, elevation: Float = 0, radius: Float = 1, bounds: CameraBounds? = nil) {
        self.azimuth = azimuth
        self.elevation = elevation
        self.radius = radius
        self.bounds = bounds
        Task { @MainActor in
            WorldCameraSystem.registerSystem()
        }
    }

    public func cameraAxisOrientation() -> simd_quatf {
        simd_quatf(angle: -azimuth, axis: [0, 1, 0]) *
            simd_quatf(angle: -elevation, axis: [1, 0, 0])
    }

    public mutating func updateWith(continuousMotion: SIMD2<Float>) {
        self.continuousMotion = continuousMotion
    }

    public mutating func updateWith(joystickMotion: SIMD2<Float>) {
        azimuth += joystickMotion.x / 50
        elevation -= joystickMotion.y / 50
        if let bounds {
            if let azimuthBounds = bounds.azimuth {
                self.azimuth = min(max(azimuthBounds.lowerBound, azimuth), azimuthBounds.upperBound)
            }
            if let elevationBounds = bounds.elevation {
                self.elevation = min(max(elevationBounds.lowerBound, elevation), elevationBounds.upperBound)
            }
        }
    }
}
