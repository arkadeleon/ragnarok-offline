//
//  MapObject.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/6.
//

import ROConstants
import RONetwork

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

public struct MapObject: Sendable {
    public let id: UInt32
    public let type: MapObjectType
    public let speed: Int16

    public let job: Int16
    public let name: String

    public let bodyState: StatusChangeOption1
    public let healthState: StatusChangeOption2
    public let effectState: StatusChangeOption

    public let position: SIMD2<Int16>

    init(packet: packet_spawn_unit) {
        self.id = packet.AID
        self.type = MapObjectType(rawValue: Int(packet.objecttype)) ?? .unknown
        self.speed = packet.speed

        self.job = packet.job
        self.name = packet.name

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing

        let posDir = PosDir(data: packet.PosDir)
        self.position = [posDir.x, posDir.y]
    }

    init(packet: packet_idle_unit) {
        self.id = packet.AID
        self.type = MapObjectType(rawValue: Int(packet.objecttype)) ?? .unknown
        self.speed = packet.speed

        self.job = packet.job
        self.name = packet.name

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing

        let posDir = PosDir(data: packet.PosDir)
        self.position = [posDir.x, posDir.y]
    }

    init(packet: packet_unit_walking) {
        self.id = packet.AID
        self.type = MapObjectType(rawValue: Int(packet.objecttype)) ?? .unknown
        self.speed = packet.speed

        self.job = packet.job
        self.name = packet.name

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing

        let moveData = MoveData(data: packet.MoveData)
        self.position = [moveData.x1, moveData.y1]
    }
}
