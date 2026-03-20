//
//  MapProjector.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import CoreGraphics
import simd

@MainActor
public protocol MapProjector: AnyObject {
    func project(_ worldPosition: SIMD3<Float>) -> CGPoint?
}
