//
//  SpriteComponent.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/22.
//

import RealityKit

public struct SpriteComponent: Component {
    public var actions: [SpriteAction]

    public init(actions: [SpriteAction]) {
        self.actions = actions
    }
}
