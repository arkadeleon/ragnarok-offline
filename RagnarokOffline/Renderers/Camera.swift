//
//  Camera.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/6.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import CoreGraphics
import simd

class Camera {
    var defaultDistance: Float = 2.5 {
        didSet {
            position = [0, 0, -defaultDistance]
        }
    }
    var minimumDistance: Float = 0
    var maximumDistance: Float = 20

    private(set) var position: simd_float3 = [0, 0, -2.5]
    private(set) var rotation: simd_float3 = [0, 0, 0]

    private(set) var target: simd_float3 = [0, 0, 0]

    var fovy: Float = 70
    var aspectRatio: Float = 1.0
    var nearZ: Float = 0.1
    var farZ: Float = 100.0

    private(set) var sensitivity: Float = 0.1

    var projectionMatrix: simd_float4x4 {
        perspective(radians(fovy), aspectRatio, nearZ, farZ)
    }

    var viewMatrix: simd_float4x4 {
        if target == position {
            let translationMatrix = simd_float4x4(translation: target)
            let rotationMatrix = simd_float4x4(rotationXYZ: rotation)
            return (translationMatrix * rotationMatrix).inverse
        } else {
            let translationMatrix = simd_float4x4(translation: position)
            let rotationMatrix = simd_float4x4(rotationXYZ: rotation)
            return (translationMatrix * rotationMatrix).inverse
        }
    }

    func update(size: CGSize) {
        aspectRatio = Float(size.width / size.height)
    }

    func update(magnification: CGFloat, dragTranslation: CGPoint) {
        var distance = defaultDistance
        distance /= Float(magnification)
        distance = max(distance, minimumDistance)
        distance = min(distance, maximumDistance)

        rotation.x = Float(dragTranslation.y) * sensitivity
        rotation.y = Float(dragTranslation.x) * sensitivity
        rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))

        let rotationMatrix = simd_float4x4(rotationXYZ: [-rotation.x, rotation.y, 0])
        let distanceVector: simd_float4 = [0, 0, -distance, 0]
        let rotatedVector = rotationMatrix * distanceVector
        position = target + [rotatedVector.x, rotatedVector.y, rotatedVector.z]
    }

    func move(offset: CGPoint) {
        target.x = -Float(offset.x) * sensitivity
        target.y = -Float(offset.y) * sensitivity
        position.x = -Float(offset.x) * sensitivity
        position.y = -Float(offset.y) * sensitivity
    }
}
