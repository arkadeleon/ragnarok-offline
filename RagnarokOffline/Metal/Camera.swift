//
//  Camera.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/6.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Spatial

class Camera {
    private(set) var position = Point3D(x: 0, y: 0, z: -2.5)
    private(set) var rotation = Rotation3D()

    private(set) var target = Point3D()

    private(set) var fovy = Angle2D(degrees: 70)
    private(set) var aspectRatio = 1.0
    private(set) var nearZ = 0.1
    private(set) var farZ = 100.0

    private(set) var sensitivity = 0.001

    var projectionMatrix: ProjectiveTransform3D {
        ProjectiveTransform3D(fovyRadians: fovy.radians, aspectRatio: aspectRatio, nearZ: nearZ, farZ: farZ)
    }

    var viewMatrix: ProjectiveTransform3D {
        if target == position {
            let translationMatrix = ProjectiveTransform3D(translation: Vector3D(target))
            let rotationMatrix = ProjectiveTransform3D(rotation: rotation)
            return (translationMatrix * rotationMatrix).inverse ?? .identity
        } else {
            let translationMatrix = ProjectiveTransform3D(translation: .zero - position)
            let rotation = Rotation3D(position: position, target: target)
            let rotationMatrix = ProjectiveTransform3D(rotation: rotation)
            return (translationMatrix * rotationMatrix).inverse ?? .identity
        }
    }

    func update(size: CGSize) {
        aspectRatio = size.width / size.height
    }

    func update(magnification: CGFloat, dragTranslation: CGPoint) {
        var distance = 2.5
        distance /= magnification
        distance = max(distance, 0)
        distance = min(distance, 20)

        let angleX = -dragTranslation.y * sensitivity
        let angleY = dragTranslation.x * sensitivity
        let angles = EulerAngles(angles: [angleX, angleY, 0], order: .pitchYawRoll)
        rotation = Rotation3D(eulerAngles: angles)

        position = target + Vector3D(x: 0, y: 0, z: -distance).rotated(by: rotation)
    }

    func move(offset: CGPoint) {
        target.x = offset.x * sensitivity
        target.y = offset.y * sensitivity
        position.x = offset.x * sensitivity
        position.y = offset.y * sensitivity
    }
}
