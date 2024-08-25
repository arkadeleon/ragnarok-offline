//
//  PACKET_CZ_REQUEST_ACT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/23.
//

/// See `clif_parse_ActionRequest`
public struct PACKET_CZ_REQUEST_ACT: EncodablePacket {
    public static var packetType: Int16 {
        packetDatabase.entryForRequestAction.packetType
    }

    public var packetLength: Int16 {
        packetDatabase.entryForRequestAction.packetLength
    }

    public var targetGID: UInt32
    public var action: UInt8

    public init() {
        targetGID = 0
        action = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let offsets = packetDatabase.entryForRequestAction.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: targetGID)
        data.replaceSubrange(from: offsets[1], with: action)

        try encoder.encode(data)
    }
}

extension PacketDatabase {
    var entryForRequestAction: Entry {
        entry(forFunctionName: "clif_parse_ActionRequest")!
    }
}
