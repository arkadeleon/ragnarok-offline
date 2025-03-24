//
//  MapObject.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/6.
//

import ROConstants
import RONetwork

public struct MapObject: Sendable {
    public let id: UInt32
    public let type: UInt8
    public let speed: Int16

    public let job: Int16
    public let name: String

    public internal(set) var bodyState: StatusChangeOption1
    public internal(set) var healthState: StatusChangeOption2
    public internal(set) var effectState: StatusChangeOption

    public internal(set) var position: SIMD2<Int16>

    init(packet: packet_spawn_unit) {
        self.id = packet.AID
        self.type = packet.objecttype
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
        self.type = packet.objecttype
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
        self.type = packet.objecttype
        self.speed = packet.speed

        self.job = packet.job
        self.name = packet.name

        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing

        let moveData = MoveData(data: packet.MoveData)
        self.position = [moveData.x1, moveData.y1]
    }

    mutating func updateState(with packet: PACKET_ZC_STATE_CHANGE) {
        bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
    }
}
