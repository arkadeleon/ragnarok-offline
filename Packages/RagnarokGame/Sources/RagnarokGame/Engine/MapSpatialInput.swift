//
//  MapSpatialInput.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/13.
//

#if os(visionOS)

import RagnarokRendering
import Spatial
import SwiftUI
import simd

/// Handles the pinches that the viewer makes in the immersive space.
///
/// There are no gesture recognizers here. Compositor Services only reports raw events, one
/// per hand per frame, so this class decides what is a tap and what is a drag.
///
/// A pinch that does not move is a tap. It selects what the viewer looks at. A pinch that
/// moves is a drag. It rotates the camera. The camera distance never changes, because the
/// headset chooses the field of view.
@MainActor
final class MapSpatialInput {
    /// A pinch is a tap if the hand moves less than this many meters.
    private static let dragThreshold: Float = 0.02

    /// How far the camera turns, in radians, when the hand moves one meter. Elevation is
    /// slower than azimuth, because elevation has a range of only 45 degrees.
    private static let azimuthPerMeter: Float = 6
    private static let elevationPerMeter: Float = 3

    private static let minimumElevation: Float = .pi / 12
    private static let maximumElevation: Float = .pi / 3

    /// How wide one view point is, at a distance of one unit.
    ///
    /// Hit testing makes a dropped item at least 30 points wide. The eye is accurate to
    /// about one degree. So one point is 1/30 of a degree, and an item is always about one
    /// degree wide.
    private static let pointWidth: Float = .pi / 180 / 30

    private weak var runtime: MapSceneRuntime?

    /// Where the map is, in the world coordinate system of the headset. This is the same
    /// coordinate system that `deviceAnchor` uses. The frame loop sets this every frame,
    /// because the game camera moves the map.
    private var worldPlacement = matrix_identity_float4x4

    /// The right and up direction of the viewer's head, in the same world coordinate
    /// system. Hand movement is measured along these two directions, so a drag to the right
    /// always works the same way, even after the viewer turns around.
    private var headRight = SIMD3<Float>(1, 0, 0)
    private var headUp = SIMD3<Float>(0, 1, 0)

    private var pinches: [SpatialEventCollection.Event.ID : Pinch] = [:]
    private var orbit: Orbit?

    init(runtime: MapSceneRuntime) {
        self.runtime = runtime
    }

    func update(worldPlacement: simd_float4x4, originFromDevice: simd_float4x4) {
        self.worldPlacement = worldPlacement
        headRight = simd_normalize(originFromDevice.columns.0.xyz)
        headUp = simd_normalize(originFromDevice.columns.1.xyz)
    }

    func handle(_ events: SpatialEventCollection) {
        for event in events {
            switch event.phase {
            case .active:
                if var pinch = pinches[event.id] {
                    pinch.position = handPosition(of: event) ?? pinch.position
                    pinch.isDragging = pinch.isDragging || pinch.travel > Self.dragThreshold
                    pinches[event.id] = pinch
                } else {
                    pinches[event.id] = Pinch(
                        startPosition: handPosition(of: event),
                        selectionRay: event.selectionRay
                    )
                }
            case .ended:
                let pinch = pinches.removeValue(forKey: event.id)
                if let pinch, !pinch.isDragging {
                    // Use the ray from the time the pinch started. When the pinch ends, the
                    // viewer usually looks at something else already.
                    select(along: pinch.selectionRay ?? event.selectionRay)
                }
            case .cancelled:
                pinches[event.id] = nil
            @unknown default:
                pinches[event.id] = nil
            }
        }

        updateCamera()
    }

    /// Where the pinching hand is, in the world coordinate system of the headset. Returns
    /// nil if the event has no hand pose.
    private func handPosition(of event: SpatialEventCollection.Event) -> SIMD3<Float>? {
        guard let pose = event.inputDevicePose else {
            return nil
        }
        return SIMD3<Float>(pose.pose3D.position.vector)
    }

    private func select(along selectionRay: Ray3D?) {
        guard let runtime, let selectionRay else {
            return
        }

        // The ray is in the world coordinate system of the headset, and the map is at
        // `worldPlacement` there. Hit testing needs the ray in the coordinate system of the
        // map, so remove that placement. The origin is a position, so it moves with the
        // map. The direction is only a direction, so it must not move with the map.
        let mapFromWorld = worldPlacement.inverse
        let origin = (mapFromWorld * SIMD4<Float>(SIMD3<Float>(selectionRay.origin.vector), 1)).xyz
        let direction = (mapFromWorld * SIMD4<Float>(SIMD3<Float>(selectionRay.direction.vector), 0)).xyz
        guard simd_length(direction) > .leastNonzeroMagnitude else {
            return
        }

        let ray = Ray(
            origin: origin,
            direction: simd_normalize(direction),
            pointWidth: Self.pointWidth
        )
        if let result = runtime.hitTest(ray) {
            runtime.scene.handleInteraction(result)
        }
    }

    private func updateCamera() {
        guard let scene = runtime?.scene else {
            return
        }

        if let orbit, let position = pinches[orbit.id]?.draggingPosition {
            let travel = position - orbit.startPosition

            let azimuth = orbit.azimuth + simd_dot(travel, headRight) * Self.azimuthPerMeter
            scene.camera.azimuth = azimuth.truncatingRemainder(dividingBy: .pi * 2)

            var elevation = orbit.elevation + simd_dot(travel, headUp) * Self.elevationPerMeter
            elevation = max(elevation, Self.minimumElevation)
            elevation = min(elevation, Self.maximumElevation)
            scene.camera.elevation = elevation
            return
        }

        // No hand rotates the camera now. Either a drag just started, or the hand that was
        // rotating the camera stopped. The new hand starts from the current camera state,
        // so the camera never jumps.
        guard let (id, pinch) = pinches.first(where: { $0.value.draggingPosition != nil }),
              let position = pinch.draggingPosition else {
            orbit = nil
            return
        }
        orbit = Orbit(
            id: id,
            startPosition: position,
            azimuth: scene.camera.azimuth,
            elevation: scene.camera.elevation
        )
    }
}

private struct Pinch {
    var startPosition: SIMD3<Float>?
    var position: SIMD3<Float>?
    var selectionRay: Ray3D?
    var isDragging = false

    var draggingPosition: SIMD3<Float>? {
        isDragging ? position : nil
    }

    var travel: Float {
        guard let startPosition, let position else {
            return 0
        }
        return simd_distance(startPosition, position)
    }

    init(startPosition: SIMD3<Float>?, selectionRay: Ray3D?) {
        self.startPosition = startPosition
        self.position = startPosition
        self.selectionRay = selectionRay
    }
}

/// The hand that rotates the camera now. The starting position and camera angles are saved when
/// the hand starts to rotate. Every change is measured from these saved values, and nothing
/// is added up frame by frame, so the camera cannot drift.
private struct Orbit {
    var id: SpatialEventCollection.Event.ID
    var startPosition: SIMD3<Float>
    var azimuth: Float
    var elevation: Float
}

#endif
