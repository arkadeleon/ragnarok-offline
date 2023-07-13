//
//  WorldDocumentCamera.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class WorldDocumentCamera: NSObject {

    var modelviewMatrix = matrix_identity_float4x4
    var normalMatrix = matrix_identity_float3x3

    var zoom: Float = 100
    var zoomFinal: Float = 100

    var angleStart: simd_float2 = [240, 0]
    var angle: simd_float2 = [240, 0]

    var position: simd_float3 = [0, 0, 0]
    var targetStart: simd_float3 = [0, 0, 0]
    var target: simd_float3 = [0, 0, 0]

    var lastTime: CFTimeInterval = 0

    var direction: Float    =    0
    var altitudeFrom: Float =  -50
    var altitudeTo: Float   =  -65
    var rotationFrom: Float = -360
    var rotationTo: Float   =  360
    var range: Float        =  240

    let panGestureRecognizer = UIPanGestureRecognizer()
    let twoFingerPanGestureRecognizer = UIPanGestureRecognizer()
    let pinchGestureRecognizer = UIPinchGestureRecognizer()
    let rotationGestureRecognizer = UIRotationGestureRecognizer()

    private var panPreviousTranslation: CGPoint = .zero
    private var pinchStartScale: Float = 0

    init(target: simd_float3) {
        super.init()

        self.lastTime = CACurrentMediaTime()

        self.targetStart = target
        self.target = target

        position[0] = -target[0]
        position[1] = -target[1]
        position[2] =  target[2]

        panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))

        twoFingerPanGestureRecognizer.minimumNumberOfTouches = 2
        twoFingerPanGestureRecognizer.addTarget(self, action: #selector(handleTwoFingerPan(_:)))

        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinch(_:)))

        rotationGestureRecognizer.addTarget(self, action: #selector(handleRotation(_:)))
    }

    func update(time: CFTimeInterval) {
        let lerp      = Float(min( (time - lastTime) * 0.006, 1.0))
        lastTime = time

        // Update camera from mouse movement
//        if (this.action.x !== -1 && this.action.y !== -1 && this.action.active) {
//            this.processMouseAction();
//        }

        // Move Camera
        let smooth = false
        if smooth {
            position[0] += ( -target[0] - position[0] ) * lerp
            position[1] += ( -target[1] - position[1] ) * lerp
            position[2] += (  target[2] - position[2] ) * lerp
        } else {
            position[0] = -target[0]
            position[1] = -target[1]
            position[2] =  target[2]
        }

        // Zoom
//        zoom        += ( zoomFinal - zoom ) * lerp * 2.0

        // Angle
//        angle[0]    += ( angleFinal[0] - angle[0] ) * lerp * 2.0
//        angle[1]    += ( angleFinal[1] - angle[1] ) * lerp * 2.0
//        angle[0]    %=   360
//        angle[1]    %=   360

        // Find Camera direction (for NPC direction)
        direction    = floor( ( angle[1] + 22.5 ) / 45 ).truncatingRemainder(dividingBy: 8);

        // Calculate new modelView mat
        modelviewMatrix = matrix_identity_float4x4
        modelviewMatrix = translateZ(modelviewMatrix, (altitudeFrom - zoom) / 2)
        modelviewMatrix = matrix_rotate(modelviewMatrix, radians(angle[0]), [1, 0, 0])
        modelviewMatrix = matrix_rotate(modelviewMatrix, radians(angle[1]), [0, 1, 0])

        // Center of the cell and inversed Y-Z axis
        var _position = simd_float3()
        _position[0] = position[0] - 0.5;
        _position[1] = position[2];
        _position[2] = position[1] - 0.5;
        modelviewMatrix = matrix_translate(modelviewMatrix, _position)

        normalMatrix = simd_float3x3(modelviewMatrix).inverse.transpose
    }

    @objc private func handlePan(_ sender: Any) {
        switch panGestureRecognizer.state {
        case .began:
            targetStart = target
        case .changed:
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            target[0] = targetStart[0] - Float(translation.x) / 3
            target[1] = targetStart[1] + Float(translation.y) / 3
        default:
            break
        }
    }

    @objc private func handleTwoFingerPan(_ sender: Any) {
        switch twoFingerPanGestureRecognizer.state {
        case .began:
            angleStart[0] = angle[0]
        case .changed:
            let translation = twoFingerPanGestureRecognizer.translation(in: twoFingerPanGestureRecognizer.view)
            angle[0] = angleStart[0] + Float(translation.y)
        default:
            break
        }
    }

    @objc private func handlePinch(_ sender: Any) {
        switch pinchGestureRecognizer.state {
        case .began:
            pinchStartScale = zoom
            zoom = pinchStartScale / Float(pinchGestureRecognizer.scale)
        case .changed:
            zoom = pinchStartScale / Float(pinchGestureRecognizer.scale)
        default:
            break
        }
    }

    @objc private func handleRotation(_ sender: Any) {
        switch rotationGestureRecognizer.state {
        case .began:
            angleStart[1] = angle[1]
        case .changed:
            angle[1] = angleStart[1] + degrees(Float(rotationGestureRecognizer.rotation))
        default:
            break
        }
    }
}

