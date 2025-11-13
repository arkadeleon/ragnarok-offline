//
//  MapObjectAction.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2025/11/12.
//

import RagnarokConstants
import RagnarokPackets

public struct MapObjectAction: Sendable {
    public let sourceObjectID: UInt32
    public let targetObjectID: UInt32
    public let type: DamageType
    public let count: Int
    public let damage: Int
    public let damage2: Int
    public let sourceSpeed: Int

    init(packet: PACKET_ZC_NOTIFY_ACT) {
        self.sourceObjectID = UInt32(packet.srcID)
        self.targetObjectID = UInt32(packet.targetID)
        self.type = DamageType(rawValue: Int(packet.type)) ?? .normal
        self.count = Int(packet.div)
        self.damage = Int(packet.damage)
        self.damage2 = Int(packet.damage2)
        self.sourceSpeed = Int(packet.srcSpeed)
    }
}
