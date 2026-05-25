//
//  MapSceneObject.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import RagnarokConstants
import RagnarokModels
import simd

public struct MapSceneObject: Sendable {
    public let objectID: GameObjectID
    public var type: MapObjectType
    public var name: String
    public var speed: Int
    public var gridPosition: SIMD2<Int>
    public var job: Int
    public var gender: Gender
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
    public var bodyState: StatusChangeOption1
    public var healthState: StatusChangeOption2
    public var effectState: StatusChangeOption
    public var movement: MapObjectMovementState?
    public var presentation: MapObjectPresentationState

    public init(
        object: MapObject,
        gridPosition: SIMD2<Int>,
        hp: Int,
        maxHp: Int,
        sp: Int? = nil,
        maxSp: Int? = nil,
        movement: MapObjectMovementState? = nil,
        presentation: MapObjectPresentationState
    ) {
        self.objectID = object.objectID
        self.type = object.type
        self.name = object.name
        self.speed = object.speed
        self.gridPosition = gridPosition
        self.job = object.job
        self.gender = object.gender
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
        self.bodyState = object.bodyState
        self.healthState = object.healthState
        self.effectState = object.effectState
        self.movement = movement
        self.presentation = presentation
    }
}
