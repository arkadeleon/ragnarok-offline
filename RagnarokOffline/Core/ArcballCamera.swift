//
//  ArcballCamera.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/6.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Spatial

struct ArcballCamera {
    var position = Point3D()
    var rotation = Rotation3D()

    var target = Point3D()

    var fovyRadians: Double = 15
    var aspectRatio: Double = 1
    var nearZ: Double = 1
    var farZ: Double = 1000

    var projectionMatrix: ProjectiveTransform3D {
        ProjectiveTransform3D(fovyRadians: fovyRadians, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }

    var viewMatrix: ProjectiveTransform3D {
        if target == position {
            let translationMatrix = ProjectiveTransform3D(translation: Vector3D(target))
            let rotationMatrix = ProjectiveTransform3D(rotation: rotation)
            return (translationMatrix * rotationMatrix).inverse ?? .identity
        } else {
            let up = Vector3D(x: 0, y: 1, z: 0)
            let rotation = Rotation3D(position: position, target: target, up: up)
            return ProjectiveTransform3D(rotation: rotation)
        }
    }

    mutating func update(size: CGSize) {
        aspectRatio = size.width / size.height
    }

    mutating func update(magnification: CGFloat, dragTranslation: CGSize) {
        var distance = 2.5
        distance /= magnification
        distance = max(distance, 0)
        distance = min(distance, 20)

        let angleX = -dragTranslation.height * 0.01
        let angleY = dragTranslation.width * 0.01
        let angles = EulerAngles(angles: [angleX, angleY, 0], order: .pitchYawRoll)
        rotation = Rotation3D(eulerAngles: angles)

        position = target + Vector3D(x: 0, y: 0, z: -distance).rotated(by: rotation)
    }
}
