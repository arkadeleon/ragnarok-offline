//
//  PACKET_CZ_REQUEST_ACT.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/23.
//

import BinaryIO

let ENTRY_CZ_REQUEST_ACT = packetDatabase.entry(forFunctionName: "clif_parse_ActionRequest")!

public struct PACKET_CZ_REQUEST_ACT: EncodablePacket {
    public let packetType: Int16
    public var targetID: UInt32
    public var action: UInt8

    public init() {
        packetType = ENTRY_CZ_REQUEST_ACT.packetType
        targetID = 0
        action = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_REQUEST_ACT.packetLength
        let offsets = ENTRY_CZ_REQUEST_ACT.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: targetID)
        data.replaceSubrange(from: offsets[1], with: action)

        try encoder.encode(data)
    }
}
