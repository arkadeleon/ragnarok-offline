//
//  Camera.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/29.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import UIKit

class Camera: NSObject {

    let pinchGestureRecognizer: UIPinchGestureRecognizer

    private(set) var fieldOfView: Float = 15 {
        didSet {
            fieldOfView = max(fieldOfView, 1)
            fieldOfView = min(fieldOfView, 45)
        }
    }

    private var pinchStartScale: Float = 0

    override init() {
        pinchGestureRecognizer = UIPinchGestureRecognizer()

        super.init()

        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinch(_:)))
    }

    @objc private func handlePinch(_ sender: Any) {
        switch pinchGestureRecognizer.state {
        case .began:
            pinchStartScale = fieldOfView
            fieldOfView = pinchStartScale / Float(pinchGestureRecognizer.scale)
        case .changed:
            fieldOfView = pinchStartScale / Float(pinchGestureRecognizer.scale)
        default:
            break
        }
    }
}
