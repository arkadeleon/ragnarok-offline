//
//  MapObject.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/6.
//

import Constants
import ROPackets

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

    public let bodyState: StatusChangeOption1
    public let healthState: StatusChangeOption2
    public let effectState: StatusChangeOption

    public init(account: AccountInfo, char: CharInfo) {
        self.objectID = account.accountID
        self.type = .pc
        self.name = char.name
        self.speed = Int(char.speed)

        self.job = Int(char.job)
        self.gender = Gender(rawValue: Int(char.sex)) ?? .female
        self.hairStyle = Int(char.hair)
        self.hairColor = Int(char.hairColor)
        self.clothesColor = Int(char.clothesColor)
        self.weapon = Int(char.weapon)
        self.shield = Int(char.shield)
        self.headTop = Int(char.headTop)
        self.headMid = Int(char.headMiddle)
        self.headBottom = Int(char.headBottom)
        self.garment = Int(char.robe)

        self.bodyState = StatusChangeOption1(rawValue: Int(char.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(char.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(char.effectState)) ?? .nothing
    }

    init(packet: packet_spawn_unit) {
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

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
    }

    init(packet: packet_idle_unit) {
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

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
    }

    init(packet: packet_unit_walking) {
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

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
    }
}
