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

final class MapSceneMapObject {
    let objectID: GameObjectID

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
    var sp: Int
    var maxSp: Int
    var bodyState: StatusChangeOption1
    var healthState: StatusChangeOption2
    var effectState: StatusChangeOption

    var gridPosition: SIMD2<Int>

    var composedSprite: ComposedSprite?

    var action: SpriteAction
    var movement: MapObjectMovement?
    var death: MapObjectDeath?
    var cast: MapObjectCast?

    /// How long one attack takes.
    var attackDelay: Duration = .milliseconds(300)

    var isDead: Bool {
        death != nil
    }

    var opacity: Float {
        death?.opacity ?? 1
    }

    init(
        account: AccountInfo,
        character: CharacterInfo,
        gridPosition: SIMD2<Int>,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
    ) {
        objectID = account.accountID

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
        sp = character.sp
        maxSp = character.maxSp
        bodyState = StatusChangeOption1(rawValue: character.bodyState) ?? .none
        healthState = StatusChangeOption2(rawValue: character.healthState) ?? .none
        effectState = StatusChangeOption(rawValue: character.effectState) ?? .nothing

        self.gridPosition = gridPosition

        action = SpriteAction(
            actionType: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: .now,
            completion: .indefinite
        )
    }

    init(
        object: MapObject,
        hp: Int,
        maxHp: Int,
        sp: Int = 0,
        maxSp: Int = 0,
        gridPosition: SIMD2<Int>,
        direction: SpriteDirection,
        headDirection: SpriteHeadDirection
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
        weaponType = ItemWeaponTypeTable.weaponType(for: object.weapon) ?? .w_fist
        shield = object.shield
        headTop = object.headTop
        headMid = object.headMid
        headBottom = object.headBottom
        garment = object.garment
        self.hp = hp
        self.maxHp = maxHp
        self.sp = sp
        self.maxSp = maxSp
        bodyState = object.bodyState
        healthState = object.healthState
        effectState = object.effectState

        self.gridPosition = gridPosition

        action = SpriteAction(
            actionType: .idle,
            direction: direction,
            headDirection: headDirection,
            startTime: .now,
            completion: .indefinite
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
        death?.update(at: time)

        if cast?.isFinished(at: time) == true {
            cast = nil
        }
    }

    func nextPosition(at time: ContinuousClock.Instant) -> SIMD2<Int>? {
        movement?.nextPosition(at: time)
    }
}
