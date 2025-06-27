//
//  SpriteComponent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/22.
//

import RealityKit

public struct SpriteComponent: Component {
    public var animations: [SpriteAnimation]

    public init(animations: [SpriteAnimation]) {
        self.animations = animations
    }
}
