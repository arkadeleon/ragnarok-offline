//
//  GameRenderConfiguration.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

public struct GameRenderConfiguration: Sendable {
    public static var `default`: GameRenderConfiguration {
        #if os(visionOS)
        GameRenderConfiguration(engine: .realityKit)
        #else
        GameRenderConfiguration(engine: .metal)
        #endif
    }

    public var engine: GameRenderEngine

    public init(engine: GameRenderEngine) {
        self.engine = engine
    }
}
