//
//  PACKET_CZ_REQUEST_ACT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/23.
//

import ROCore

/// See `clif_parse_ActionRequest`
public struct PACKET_CZ_REQUEST_ACT: EncodablePacket {
    public var packetType: Int16 {
        PacketDatabase.Entry.CZ_REQUEST_ACT.packetType
    }

    public var packetLength: Int16 {
        PacketDatabase.Entry.CZ_REQUEST_ACT.packetLength
    }

    public var targetID: UInt32
    public var action: UInt8

    public init() {
        targetID = 0
        action = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let offsets = PacketDatabase.Entry.CZ_REQUEST_ACT.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: targetID)
        data.replaceSubrange(from: offsets[1], with: action)

        try encoder.encodeBytes(data)
    }
}

extension PacketDatabase.Entry {
    public static let CZ_REQUEST_ACT = packetDatabase.entry(forFunctionName: "clif_parse_ActionRequest")!
}
