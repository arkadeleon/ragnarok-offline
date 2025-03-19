//
//  Camera.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/6.
//

import CoreGraphics
import ROCore
import simd

public class Camera {
    public var defaultDistance: Float = 2.5 {
        didSet {
            position = [0, 0, -defaultDistance]
        }
    }
    public var minimumDistance: Float = 0
    public var maximumDistance: Float = 20

    public private(set) var position: SIMD3<Float> = [0, 0, -2.5]
    public private(set) var rotation: SIMD3<Float> = [0, 0, 0]

    public private(set) var target: SIMD3<Float> = [0, 0, 0]

    public var fovy: Float = 70
    public var aspectRatio: Float = 1.0
    public var nearZ: Float = 0.1
    public var farZ: Float = 100.0

    public private(set) var sensitivity: Float = 0.1

    public var projectionMatrix: float4x4 {
        perspective(radians(fovy), aspectRatio, nearZ, farZ)
    }

    public var viewMatrix: float4x4 {
        if target == position {
            let translationMatrix = float4x4(translation: target)
            let rotationMatrix = float4x4(rotationXYZ: rotation)
            return (translationMatrix * rotationMatrix).inverse
        } else {
            let translationMatrix = float4x4(translation: position)
            let rotationMatrix = float4x4(rotationXYZ: rotation)
            return (translationMatrix * rotationMatrix).inverse
        }
    }

    public init() {
    }

    public func update(size: CGSize) {
        aspectRatio = Float(size.width / size.height)
    }

    public func update(magnification: CGFloat, dragTranslation: CGPoint) {
        var distance = defaultDistance
        distance /= Float(magnification)
        distance = max(distance, minimumDistance)
        distance = min(distance, maximumDistance)

        rotation.x = Float(dragTranslation.y) * sensitivity
        rotation.y = Float(dragTranslation.x) * sensitivity
        rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))

        let rotationMatrix = float4x4(rotationXYZ: [-rotation.x, rotation.y, 0])
        let distanceVector: SIMD4<Float> = [0, 0, -distance, 0]
        let rotatedVector = rotationMatrix * distanceVector
        position = target + [rotatedVector.x, rotatedVector.y, rotatedVector.z]
    }

    public func move(offset: CGPoint) {
        target.x = -Float(offset.x) * sensitivity
        target.y = -Float(offset.y) * sensitivity
        position.x = -Float(offset.x) * sensitivity
        position.y = -Float(offset.y) * sensitivity
    }
}
