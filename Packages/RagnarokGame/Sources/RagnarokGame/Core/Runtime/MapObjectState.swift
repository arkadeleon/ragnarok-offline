//
//  MapObjectState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import RagnarokModels
import simd

public struct MapObjectState: Identifiable, Sendable {
    public let id: GameObjectID
    public var object: MapObject
    public var gridPosition: SIMD2<Int>
    public var job: Int
    public var hairStyle: Int
    public var hairColor: Int
    public var clothesColor: Int
    public var weapon: Int
    public var shield: Int
    public var headTop: Int
    public var headMid: Int
    public var headBottom: Int
    public var garment: Int
    public var hp: Int
    public var maxHp: Int
    public var sp: Int?
    public var maxSp: Int?
    public var isVisible: Bool
    public var movement: MapObjectMovementState?
    public var presentation: MapObjectPresentationState

    public init(
        id: GameObjectID,
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
        self.job = object.job
        self.hairStyle = object.hairStyle
        self.hairColor = object.hairColor
        self.clothesColor = object.clothesColor
        self.weapon = object.weapon
        self.shield = object.shield
        self.headTop = object.headTop
        self.headMid = object.headMid
        self.headBottom = object.headBottom
        self.garment = object.garment
        self.hp = hp
        self.maxHp = maxHp
        self.sp = sp
        self.maxSp = maxSp
        self.isVisible = isVisible
        self.movement = movement
        self.presentation = presentation
    }
}
