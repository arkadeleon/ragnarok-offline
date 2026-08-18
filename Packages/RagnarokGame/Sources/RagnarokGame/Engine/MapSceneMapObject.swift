//
//  MapSceneMapObject.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import RagnarokConstants
import RagnarokModels
import RagnarokSprite
import simd

class MapSceneMapObject: SpriteObject {
    var type: MapObjectType
    var name: String
    var speed: Int
    var job: Int
    var gender: Gender
    var hairStyle: Int
    var hairColor: Int
    var clothesColor: Int
    var weaponType: WeaponType
    var shield: Int
    var headTop: Int
    var headMid: Int
    var headBottom: Int
    var garment: Int
    var hp: Int
    var maxHp: Int
    var bodyState: StatusChangeOption1
    var healthState: StatusChangeOption2
    var effectState: StatusChangeOption

    var action: SpriteAction
    var movement: MapObjectMovement?

    var spriteConfiguration: ComposedSprite.Configuration?
    var composedSprite: ComposedSprite?
    var partTextures: SpritePartTextures?

    var ownedEffects: [MapSceneEffect] = []

    init(
        account: AccountInfo,
        character: CharacterInfo,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
    ) {
        type = .pc
        name = character.name
        speed = character.speed
        job = character.job
        gender = Gender(rawValue: character.sex) ?? .female
        hairStyle = character.head
        hairColor = character.headPalette
        clothesColor = character.bodyPalette
        weaponType = WeaponType(rawValue: character.weapon) ?? .w_fist
        shield = character.shield
        headTop = character.accessory2
        headMid = character.accessory3
        headBottom = character.accessory
        garment = character.robePalette
        hp = character.hp
        maxHp = character.maxHp
        bodyState = StatusChangeOption1(rawValue: character.bodyState) ?? .none
        healthState = StatusChangeOption2(rawValue: character.healthState) ?? .none
        effectState = StatusChangeOption(rawValue: character.effectState) ?? .nothing

        action = SpriteAction(
            actionType: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: .now,
            completion: .indefinite
        )

        super.init(
            objectID: account.accountID,
            gridPosition: gridPosition,
            worldPosition: worldPosition
        )
    }

    init(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
    ) {
        type = object.type
        name = object.name
        speed = object.speed
        job = object.job
        gender = object.gender
        hairStyle = object.hairStyle
        hairColor = object.hairColor
        clothesColor = object.clothesColor
        weaponType = ItemWeaponTypeTable.weaponType(for: object.weapon) ?? .w_fist
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

        action = SpriteAction(
            actionType: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: .now,
            completion: .indefinite
        )

        super.init(
            objectID: object.objectID,
            gridPosition: gridPosition,
            worldPosition: worldPosition
        )
    }

    func perform(_ actionType: SpriteActionType, completion: SpriteAction.Completion, at time: ContinuousClock.Instant = .now) {
        action.actionType = actionType
        action.startTime = time
        action.elapsedTime = .zero
        action.completion = completion
    }

    func turn(direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        action.direction = direction
        action.headDirection = headDirection
    }

    func setDirection(_ direction: SpriteDirection) {
        action.direction = direction
    }

    func replanMovement(
        startPosition: SIMD2<Int>,
        endPosition: SIMD2<Int>,
        speed: Int,
        pathFinder: PathFinder,
        mapGrid: MapGrid,
        at time: ContinuousClock.Instant = .now
    ) -> MapObjectMovement {
        let planner = MapObjectMovementPlanner(pathFinder: pathFinder)
        var planned = planner.replan(
            existingMovement: movement,
            incomingStartPosition: startPosition,
            incomingEndPosition: endPosition,
            speed: speed,
            at: time
        )
        planned.updateWorldPath { mapGrid.worldPosition(for: $0) }
        planned.update(atTime: time)
        movement = planned
        return planned
    }

    func stopMovement() {
        movement = nil
    }

    func update(at time: ContinuousClock.Instant) {
        action.update(atTime: time)
        movement?.update(atTime: time)
    }

    func nextPosition(at time: ContinuousClock.Instant) -> SIMD2<Int>? {
        movement?.nextPosition(at: time)
    }
}

extension MapSceneMapObject {
    static func make(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        sp: Int = 0,
        maxSp: Int = 0,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
    ) -> MapSceneMapObject {
        switch object.type {
        case .pc:
            MapScenePlayerObject(
                object: object,
                hp: hp,
                maxHp: maxHp,
                sp: sp,
                maxSp: maxSp,
                gridPosition: gridPosition,
                worldPosition: worldPosition,
                direction: direction,
                headDirection: headDirection
            )
        case .monster:
            MapSceneMonsterObject(
                object: object,
                hp: hp,
                maxHp: maxHp,
                gridPosition: gridPosition,
                worldPosition: worldPosition,
                direction: direction,
                headDirection: headDirection
            )
        default:
            MapSceneNPCObject(
                object: object,
                hp: hp,
                maxHp: maxHp,
                gridPosition: gridPosition,
                worldPosition: worldPosition,
                direction: direction,
                headDirection: headDirection
            )
        }
    }
}

final class MapScenePlayerObject: MapSceneMapObject {
    var sp: Int
    var maxSp: Int

    override init(
        account: AccountInfo,
        character: CharacterInfo,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
    ) {
        sp = character.sp
        maxSp = character.maxSp
        super.init(
            account: account,
            character: character,
            gridPosition: gridPosition,
            worldPosition: worldPosition,
            direction: direction,
            headDirection: headDirection
        )
    }

    init(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        sp: Int,
        maxSp: Int,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
    ) {
        self.sp = sp
        self.maxSp = maxSp
        super.init(
            object: object,
            hp: hp,
            maxHp: maxHp,
            gridPosition: gridPosition,
            worldPosition: worldPosition,
            direction: direction,
            headDirection: headDirection
        )
    }
}

final class MapSceneMonsterObject: MapSceneMapObject {}

final class MapSceneNPCObject: MapSceneMapObject {}

extension ComposedSprite.Configuration {
    init(object: MapSceneMapObject) {
        self.init(jobID: object.job)
        self.gender = object.gender
        self.hairStyle = object.hairStyle
        self.hairColor = object.hairColor
        self.clothesColor = object.clothesColor
        self.weapon = object.weaponType.rawValue
        self.shield = object.shield
        self.headgears = [object.headTop, object.headMid, object.headBottom]
        self.garment = object.garment

        self.updateHairStyle()
    }
}
