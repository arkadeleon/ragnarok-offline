//
//  MapObject.swift
//  RagnarokModels
//
//  Created by Leon Li on 2024/12/6.
//

import RagnarokConstants
import RagnarokPackets

// See `clif_bl_type`
public enum MapObjectType: Int, Sendable {
    case pc = 0x0
    case disguised = 0x1
    case item = 0x2
    case skill = 0x3
    case unknown = 0x4
    case monster = 0x5
    case npc = 0x6
    case pet = 0x7
    case hom = 0x8
    case mer = 0x9
    case elem = 0xa
    case npc2 = 0xc
    case abr = 0xd
    case bionic = 0xe
}

/// Represents a player character, non-player character, monster on a map.
public struct MapObject: Sendable {
    public let objectID: UInt32
    public let type: MapObjectType
    public let name: String
    public let speed: Int

    public let job: Int
    public let gender: Gender
    public let hairStyle: Int
    public let hairColor: Int
    public let clothesColor: Int
    public let weapon: Int
    public let shield: Int
    public let headTop: Int
    public let headMid: Int
    public let headBottom: Int
    public let garment: Int

    public let hp: Int
    public let maxHp: Int

    public let bodyState: StatusChangeOption1
    public let healthState: StatusChangeOption2
    public let effectState: StatusChangeOption

    public init(account: AccountInfo, character: CharacterInfo) {
        self.objectID = account.accountID
        self.type = .pc
        self.name = character.name
        self.speed = character.speed

        self.job = character.job
        self.gender = Gender(rawValue: character.sex) ?? .female
        self.hairStyle = character.head
        self.hairColor = character.headPalette
        self.clothesColor = character.bodyPalette
        self.weapon = character.weapon
        self.shield = character.shield
        self.headTop = character.accessory2
        self.headMid = character.accessory3
        self.headBottom = character.accessory
        self.garment = character.robePalette

        self.hp = character.hp
        self.maxHp = character.maxHp

        self.bodyState = StatusChangeOption1(rawValue: character.bodyState) ?? .none
        self.healthState = StatusChangeOption2(rawValue: character.healthState) ?? .none
        self.effectState = StatusChangeOption(rawValue: character.effectState) ?? .nothing
    }

    public init(from packet: packet_spawn_unit) {
        self.objectID = packet.AID
        self.type = MapObjectType(rawValue: Int(packet.objecttype)) ?? .unknown
        self.name = packet.name
        self.speed = Int(packet.speed)

        self.job = Int(packet.job)
        self.gender = Gender(rawValue: Int(packet.sex)) ?? .female
        self.hairStyle = Int(packet.head)
        self.hairColor = Int(packet.headpalette)
        self.clothesColor = Int(packet.bodypalette)
        self.weapon = Int(packet.weapon)
        self.shield = Int(packet.shield)
        self.headTop = Int(packet.accessory2)
        self.headMid = Int(packet.accessory3)
        self.headBottom = Int(packet.accessory)
        self.garment = Int(packet.robe)

        self.hp = Int(packet.HP)
        self.maxHp = Int(packet.maxHP)

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
    }

    public init(from packet: packet_idle_unit) {
        self.objectID = packet.AID
        self.type = MapObjectType(rawValue: Int(packet.objecttype)) ?? .unknown
        self.name = packet.name
        self.speed = Int(packet.speed)

        self.job = Int(packet.job)
        self.gender = Gender(rawValue: Int(packet.sex)) ?? .female
        self.hairStyle = Int(packet.head)
        self.hairColor = Int(packet.headpalette)
        self.clothesColor = Int(packet.bodypalette)
        self.weapon = Int(packet.weapon)
        self.shield = Int(packet.shield)
        self.headTop = Int(packet.accessory2)
        self.headMid = Int(packet.accessory3)
        self.headBottom = Int(packet.accessory)
        self.garment = Int(packet.robe)

        self.hp = Int(packet.HP)
        self.maxHp = Int(packet.maxHP)

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
    }

    public init(from packet: packet_unit_walking) {
        self.objectID = packet.AID
        self.type = MapObjectType(rawValue: Int(packet.objecttype)) ?? .unknown
        self.name = packet.name
        self.speed = Int(packet.speed)

        self.job = Int(packet.job)
        self.gender = Gender(rawValue: Int(packet.sex)) ?? .female
        self.hairStyle = Int(packet.head)
        self.hairColor = Int(packet.headpalette)
        self.clothesColor = Int(packet.bodypalette)
        self.weapon = Int(packet.weapon)
        self.shield = Int(packet.shield)
        self.headTop = Int(packet.accessory2)
        self.headMid = Int(packet.accessory3)
        self.headBottom = Int(packet.accessory)
        self.garment = Int(packet.robe)

        self.hp = Int(packet.HP)
        self.maxHp = Int(packet.maxHP)

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
    }
}
