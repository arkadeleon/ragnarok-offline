//
//  MapOverlaySnapshot.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Observation

@MainActor
@Observable
public final class MapOverlaySnapshot {
    public var anchors: [UInt32 : MapOverlayAnchor] = [:]
}
