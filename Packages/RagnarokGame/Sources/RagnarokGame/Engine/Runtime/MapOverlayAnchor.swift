//
//  MapOverlayAnchor.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import RagnarokModels
import simd

public struct MapOverlayAnchor: Identifiable, Sendable {
    public let id: UInt32
    public var hp: Int
    public var maxHp: Int
    public var sp: Int?
    public var maxSp: Int?
    public var objectType: MapObjectType
    public var gaugePosition: SIMD3<Float>?
}
