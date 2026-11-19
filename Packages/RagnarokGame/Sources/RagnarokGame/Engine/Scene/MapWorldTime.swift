//
//  MapWorldTime.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/11/19.
//

import Foundation

struct MapWorldTime: Sendable {
    /// Monotonic time in seconds (`CACurrentMediaTime()`), matching `RenderFrame.time`.
    let time: TimeInterval

    /// Clamped frame step in seconds.
    let deltaTime: TimeInterval
}
