//
//  RealityMapProjector.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

#if os(iOS) || os(macOS)

import CoreGraphics
import RealityKit
import simd

@MainActor
final class RealityMapProjector: MapProjector {
    let arView: ARView

    init(arView: ARView) {
        self.arView = arView
    }

    func project(_ worldPosition: SIMD3<Float>) -> CGPoint? {
        guard var screenPoint = arView.project(worldPosition) else {
            return nil
        }
        #if os(macOS)
        screenPoint.y = arView.bounds.height - screenPoint.y
        #endif
        return screenPoint
    }
}

#endif
