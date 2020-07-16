//
//  WorldPreviewCamera.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import SGLMath

class WorldPreviewCamera: NSObject {

    var modelviewMatrix: Matrix4x4<Float> = Matrix4x4()
    var normalMatrix: Matrix3x3<Float> = Matrix3x3()

    var zoom: Float = 50
    var zoomFinal: Float = 50

    var angle: Vector2<Float> = [0, 0]
    var angleFinal: Vector2<Float> = [0, 0]

    var position: Vector3<Float> = [0, 0, 0]
    var target: Vector3<Float> = [0, 0, 0]

    var lastTime: CFTimeInterval = 0

    var direction: Float    =    0
    var altitudeFrom: Float =  -50
    var altitudeTo: Float   =  -65
    var rotationFrom: Float = -360
    var rotationTo: Float   =  360
    var range: Float        =  240

    let pinchGestureRecognizer = UIPinchGestureRecognizer()

    private var panPreviousTranslation: CGPoint = .zero
    private var pinchStartScale: Float = 0

    init(target: Vector3<Float>) {
        super.init()

        self.lastTime = CACurrentMediaTime()

        self.target = target

        angle[0]      = 240.0
        angle[1]      = rotationFrom % 360.0
        angleFinal[0] = range % 360.0
        angleFinal[1] = rotationFrom % 360.0

        position[0] = -target[0]
        position[1] = -target[1]
        position[2] =  target[2]

        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinch(_:)))
    }

    func update(time: CFTimeInterval) {
        let lerp      = Float(min( (time - lastTime) * 0.006, 1.0))
        lastTime = time

        // Update camera from mouse movement
//        if (this.action.x !== -1 && this.action.y !== -1 && this.action.active) {
//            this.processMouseAction();
//        }

        // Move Camera
        let smooth = true
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
        angle[0]    += ( angleFinal[0] - angle[0] ) * lerp * 2.0
        angle[1]    += ( angleFinal[1] - angle[1] ) * lerp * 2.0
        angle[0]    %=   360
        angle[1]    %=   360

        // Find Camera direction (for NPC direction)
        direction    = floor( ( angle[1] + 22.5 ) / 45 ) % 8;

        // Calculate new modelView mat
        modelviewMatrix = Matrix4x4<Float>()
        modelviewMatrix = SGLMath.translateZ(modelviewMatrix, (altitudeFrom - zoom) / 2)
        modelviewMatrix = SGLMath.rotate(modelviewMatrix, radians(angle[0]), [1, 0, 0])
        modelviewMatrix = SGLMath.rotate(modelviewMatrix, radians(angle[1]), [0, 1, 0])

        // Center of the cell and inversed Y-Z axis
        var _position: Vector3<Float> = Vector3()
        _position[0] = position[0] - 0.5;
        _position[1] = position[2];
        _position[2] = position[1] - 0.5;
        modelviewMatrix = SGLMath.translate(modelviewMatrix, _position)

        normalMatrix = Matrix3x3(modelviewMatrix).inverse.transpose
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
}

