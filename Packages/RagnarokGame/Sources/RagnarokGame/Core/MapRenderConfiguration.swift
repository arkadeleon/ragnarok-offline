//
//  MapRenderConfiguration.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

public struct MapRenderConfiguration: Sendable {
    public static var `default`: MapRenderConfiguration {
        #if os(visionOS)
        MapRenderConfiguration(engine: .realityKit)
        #else
        MapRenderConfiguration(engine: .metal)
        #endif
    }

    public var engine: MapRenderEngine

    public init(engine: MapRenderEngine) {
        self.engine = engine
    }
}
