//
//  Camera.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/6.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Spatial

struct Camera {
    var position: simd_float3 = [0, 0, -2.5]
    var rotation = Rotation3D()

    var target: simd_float3 = [0, 0, 0]

    var fovy = Angle2D(degrees: 70)
    var aspectRatio = 1.0
    var nearZ = 0.1
    var farZ = 100.0

    var sensitivity = 0.01

    var projectionMatrix: ProjectiveTransform3D {
        ProjectiveTransform3D(fovyRadians: fovy.radians, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }

    var viewMatrix: ProjectiveTransform3D {
        if target == position {
            let translationMatrix = ProjectiveTransform3D(translation: Vector3D(target))
            let rotationMatrix = ProjectiveTransform3D(rotation: rotation)
            return (translationMatrix * rotationMatrix).inverse ?? .identity
        } else {
            let position = Point3D(position)
            let target = Point3D(target)
            let translationMatrix = ProjectiveTransform3D(translation: target - position)
            let rotation = Rotation3D(position: position, target: target)
            let rotationMatrix = ProjectiveTransform3D(rotation: rotation)
            return (translationMatrix * rotationMatrix).inverse ?? .identity
        }
    }

    mutating func update(size: CGSize) {
        aspectRatio = size.width / size.height
    }

    mutating func update(magnification: CGFloat, dragTranslation: CGPoint) {
        var distance = 2.5
        distance /= magnification
        distance = max(distance, 0)
        distance = min(distance, 20)

        let angleX = -dragTranslation.y * sensitivity
        let angleY = dragTranslation.x * sensitivity
        let angles = EulerAngles(angles: [angleX, angleY, 0], order: .pitchYawRoll)
        rotation = Rotation3D(eulerAngles: angles)

        let target = Point3D(target)
        let position = target + Vector3D(x: 0, y: 0, z: -distance).rotated(by: rotation)
        self.position = [Float(position.x), Float(position.y), Float(position.z)]
    }
}
