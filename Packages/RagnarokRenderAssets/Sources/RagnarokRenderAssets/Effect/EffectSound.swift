//
//  EffectSound.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/8/25.
//

import Foundation

public struct EffectSound: Sendable {
    public let name: String
    public let delay: TimeInterval

    init(name: String, delay: TimeInterval) {
        self.name = name
        self.delay = delay
    }
}
