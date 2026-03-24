//
//  MapObjectState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import RagnarokModels
import simd

public struct MapObjectState: Identifiable, Sendable {
    public let id: UInt32
    public var object: MapObject
    public var gridPosition: SIMD2<Int>
    public var hp: Int
    public var maxHp: Int
    public var sp: Int?
    public var maxSp: Int?
    public var isVisible: Bool
    public var movement: MapObjectMovementState?
    public var presentation: MapObjectPresentationState

    public init(
        id: UInt32,
        object: MapObject,
        gridPosition: SIMD2<Int>,
        hp: Int,
        maxHp: Int,
        sp: Int? = nil,
        maxSp: Int? = nil,
        isVisible: Bool = true,
        movement: MapObjectMovementState? = nil,
        presentation: MapObjectPresentationState
    ) {
        self.id = id
        self.object = object
        self.gridPosition = gridPosition
        self.hp = hp
        self.maxHp = maxHp
        self.sp = sp
        self.maxSp = maxSp
        self.isVisible = isVisible
        self.movement = movement
        self.presentation = presentation
    }
}
