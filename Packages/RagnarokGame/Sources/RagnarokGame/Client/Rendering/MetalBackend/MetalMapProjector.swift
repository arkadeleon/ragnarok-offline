//
//  MetalMapProjector.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

#if os(iOS) || os(macOS)

import CoreGraphics
import simd

final class MetalMapProjector: MapProjector {
    func project(_ worldPosition: SIMD3<Float>) -> CGPoint? {
        nil
    }
}

#endif
