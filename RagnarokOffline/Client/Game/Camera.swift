//
//  Camera.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/29.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import SGLMath

class Camera: NSObject {

    private(set) var position: Vector3<Float> = [0, 0, 3]
    private(set) var front: Vector3<Float> = [0, 0, -1]
    private(set) var up: Vector3<Float> = [0, 1, 0]

    private(set) var pitch: Float = 0 {
        didSet {
            pitch = max(pitch, -89)
            pitch = min(pitch, 90)

            let direction: Vector3<Float> = [
                cos(radians(yaw)) * cos(radians(pitch)),
                sin(radians(pitch)),
                sin(radians(yaw)) * cos(radians(pitch))
            ]
            front = normalize(direction)
        }
    }

    private(set) var yaw: Float = -90 {
        didSet {
            let direction: Vector3<Float> = [
                cos(radians(yaw)) * cos(radians(pitch)),
                sin(radians(pitch)),
                sin(radians(yaw)) * cos(radians(pitch))
            ]
            front = normalize(direction)
        }
    }

    private(set) var zoom: Float = 15 {
        didSet {
            zoom = max(zoom, 1)
            zoom = min(zoom, 90)
        }
    }

    let panGestureRecognizer = UIPanGestureRecognizer()
    let pinchGestureRecognizer = UIPinchGestureRecognizer()

    private var panPreviousTranslation: CGPoint = .zero
    private var pinchStartScale: Float = 0

    override init() {
        super.init()

        panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinch(_:)))
    }

    @objc private func handlePan(_ sender: Any) {
        switch panGestureRecognizer.state {
        case .began:
            panPreviousTranslation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        case .changed:
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            let offset = CGPoint(x: translation.x - panPreviousTranslation.x, y: translation.y - panPreviousTranslation.y)
            let sensitivity: Float = 0.1
            pitch += Float(-offset.y) * sensitivity
            yaw += Float(offset.x) * sensitivity
            panPreviousTranslation = translation
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
}
