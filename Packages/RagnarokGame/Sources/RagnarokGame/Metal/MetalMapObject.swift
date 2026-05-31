//
//  MetalMapObject.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if !os(visionOS)

import RagnarokConstants
import RagnarokModels
import RagnarokSprite
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

    public let animationController: MetalAnimationController
    public let movementController: MetalMovementController
    public let presentation: MetalObjectPresentation

    init(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        gridPosition: SIMD2<Int>,
        mapGrid: MapGrid,
        pathFinder: PathFinder,
        direction: SpriteDirection = .south,
        headDirection: SpriteHeadDirection = .lookForward
    ) {
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

        animationController = MetalAnimationController(direction: direction, headDirection: headDirection)
        movementController = MetalMovementController(pathFinder: pathFinder, mapGrid: mapGrid)
        presentation = MetalObjectPresentation(worldPosition: mapGrid.worldPosition(for: gridPosition))
    }

    static func make(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        sp: Int = 0,
        maxSp: Int = 0,
        gridPosition: SIMD2<Int>,
        mapGrid: MapGrid,
        pathFinder: PathFinder,
        direction: SpriteDirection = .south,
        headDirection: SpriteHeadDirection = .lookForward
    ) -> MetalMapObject {
        switch object.type {
        case .pc:
            MetalPlayerObject(
                object: object,
                hp: hp,
                maxHp: maxHp,
                sp: sp,
                maxSp: maxSp,
                gridPosition: gridPosition,
                mapGrid: mapGrid,
                pathFinder: pathFinder,
                direction: direction,
                headDirection: headDirection
            )
        case .monster:
            MetalMonsterObject(
                object: object,
                hp: hp,
                maxHp: maxHp,
                gridPosition: gridPosition,
                mapGrid: mapGrid,
                pathFinder: pathFinder,
                direction: direction,
                headDirection: headDirection
            )
        default:
            MetalNPCObject(
                object: object,
                hp: hp,
                maxHp: maxHp,
                gridPosition: gridPosition,
                mapGrid: mapGrid,
                pathFinder: pathFinder,
                direction: direction,
                headDirection: headDirection
            )
        }
    }
}

@MainActor
public final class MetalPlayerObject: MetalMapObject {
    public var sp: Int
    public var maxSp: Int

    init(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        sp: Int,
        maxSp: Int,
        gridPosition: SIMD2<Int>,
        mapGrid: MapGrid,
        pathFinder: PathFinder,
        direction: SpriteDirection = .south,
        headDirection: SpriteHeadDirection = .lookForward
    ) {
        self.sp = sp
        self.maxSp = maxSp
        super.init(
            object: object,
            hp: hp,
            maxHp: maxHp,
            gridPosition: gridPosition,
            mapGrid: mapGrid,
            pathFinder: pathFinder,
            direction: direction,
            headDirection: headDirection
        )
    }
}

@MainActor
public final class MetalMonsterObject: MetalMapObject {}

@MainActor
public final class MetalNPCObject: MetalMapObject {}

extension ComposedSprite.Configuration {
    @MainActor
    init(object: MetalMapObject) {
        self.init(jobID: object.job)
        self.gender = object.gender
        self.hairStyle = object.hairStyle
        self.hairColor = object.hairColor
        self.clothesColor = object.clothesColor
        self.weapon = object.weapon
        self.shield = object.shield
        self.headgears = [object.headTop, object.headMid, object.headBottom]
        self.garment = object.garment

        self.updateHairStyle()
    }
}

#endif
