//
//  PACKET_CZ_REQ_TAKEOFF_EQUIP.swift
//  NetworkPackets
//
//  Created by Leon Li on 2025/4/15.
//

import BinaryIO

let ENTRY_CZ_REQ_TAKEOFF_EQUIP = packetDatabase.entry(forFunctionName: "clif_parse_UnequipItem")!

public struct PACKET_CZ_REQ_TAKEOFF_EQUIP: BinaryEncodable {
    public let packetType: Int16
    public var index: UInt16

    public init() {
        packetType = ENTRY_CZ_REQ_TAKEOFF_EQUIP.packetType
        index = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_REQ_TAKEOFF_EQUIP.packetLength
        let offsets = ENTRY_CZ_REQ_TAKEOFF_EQUIP.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: index)

        try encoder.encode(data)
    }
}
