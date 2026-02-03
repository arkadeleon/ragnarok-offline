//
//  KeyboardAnimation.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/16.
//

import SwiftUI

extension Animation {
    #if os(iOS)
    static func keyboard(curve: UInt, duration: Double) -> Animation {
        let animationOptions = UIView.AnimationOptions(rawValue: curve)
        if animationOptions.contains(.curveEaseInOut) {
            return .easeInOut(duration: duration)
        } else if animationOptions.contains(.curveEaseIn) {
            return .easeIn(duration: duration)
        } else if animationOptions.contains(.curveEaseOut) {
            return .easeOut(duration: duration)
        } else if animationOptions.contains(.curveLinear) {
            return .linear(duration: duration)
        } else {
            return .easeInOut(duration: duration)
        }
    }
    #endif
}
