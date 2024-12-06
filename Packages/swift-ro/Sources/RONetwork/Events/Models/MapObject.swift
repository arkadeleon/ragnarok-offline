//
//  MapObject.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/6.
//

import ROGenerated

public struct MapObject: Sendable {
    public let id: UInt32
    public let type: UInt8
    public let speed: Int16
    public let bodyState: StatusChangeOption1
    public let healthState: StatusChangeOption2
    public let effectState: StatusChangeOption
    public let job: Int16
    public let name: String

    init(packet: packet_spawn_unit) {
        self.id = packet.AID
        self.type = packet.objecttype
        self.speed = packet.speed
        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
        self.job = packet.job
        self.name = packet.name
    }

    init(packet: packet_idle_unit) {
        self.id = packet.AID
        self.type = packet.objecttype
        self.speed = packet.speed
        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
        self.job = packet.job
        self.name = packet.name
    }

    init(packet: packet_unit_walking) {
        self.id = packet.AID
        self.type = packet.objecttype
        self.speed = packet.speed
        self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
        self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
        self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
        self.job = packet.job
        self.name = packet.name
    }
}
