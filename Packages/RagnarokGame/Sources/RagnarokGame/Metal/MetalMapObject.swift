//
//  MetalMapObject.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if !os(visionOS)

import RagnarokConstants
import RagnarokModels
import simd

@MainActor
public class MetalMapObject {
    public let objectID: GameObjectID
    public var type: MapObjectType
    public var name: String
    public var speed: Int
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
    public var bodyState: StatusChangeOption1
    public var healthState: StatusChangeOption2
    public var effectState: StatusChangeOption
    public var gridPosition: SIMD2<Int>

    init(object: MapObject, hp: Int, maxHp: Int, gridPosition: SIMD2<Int>) {
        objectID = object.objectID
        type = object.type
        name = object.name
        speed = object.speed
        job = object.job
        gender = object.gender
        hairStyle = object.hairStyle
        hairColor = object.hairColor
        clothesColor = object.clothesColor
        weapon = object.weapon
        shield = object.shield
        headTop = object.headTop
        headMid = object.headMid
        headBottom = object.headBottom
        garment = object.garment
        self.hp = hp
        self.maxHp = maxHp
        bodyState = object.bodyState
        healthState = object.healthState
        effectState = object.effectState
        self.gridPosition = gridPosition
    }

    static func make(object: MapObject, hp: Int, maxHp: Int, sp: Int = 0, maxSp: Int = 0, gridPosition: SIMD2<Int>) -> MetalMapObject {
        switch object.type {
        case .pc:
            return MetalPlayerObject(object: object, hp: hp, maxHp: maxHp, sp: sp, maxSp: maxSp, gridPosition: gridPosition)
        case .monster:
            return MetalMonsterObject(object: object, hp: hp, maxHp: maxHp, gridPosition: gridPosition)
        default:
            return MetalNPCObject(object: object, hp: hp, maxHp: maxHp, gridPosition: gridPosition)
        }
    }
}

@MainActor
public final class MetalPlayerObject: MetalMapObject {
    public var sp: Int
    public var maxSp: Int

    init(object: MapObject, hp: Int, maxHp: Int, sp: Int, maxSp: Int, gridPosition: SIMD2<Int>) {
        self.sp = sp
        self.maxSp = maxSp
        super.init(object: object, hp: hp, maxHp: maxHp, gridPosition: gridPosition)
    }
}

@MainActor
public final class MetalMonsterObject: MetalMapObject {}

@MainActor
public final class MetalNPCObject: MetalMapObject {}

#endif
