//
//  MapInputIntent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import CoreGraphics

public struct MapInputIntent: Sendable {
    public var movementValue: CGPoint

    public init(movementValue: CGPoint) {
        self.movementValue = movementValue
    }
}
