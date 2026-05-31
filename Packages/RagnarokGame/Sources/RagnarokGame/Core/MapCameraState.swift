//
//  MapCameraState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

public struct MapCameraState: Sendable {
    public var azimuth: Float
    public var elevation: Float
    public var distance: Float

    public static var `default`: MapCameraState {
        #if os(visionOS)
        MapCameraState(azimuth: 0, elevation: .pi / 12, distance: 15)
        #else
        MapCameraState(azimuth: 0, elevation: .pi / 4, distance: 100)
        #endif
    }

    public init(azimuth: Float, elevation: Float, distance: Float) {
        self.azimuth = azimuth
        self.elevation = elevation
        self.distance = distance
    }
}
