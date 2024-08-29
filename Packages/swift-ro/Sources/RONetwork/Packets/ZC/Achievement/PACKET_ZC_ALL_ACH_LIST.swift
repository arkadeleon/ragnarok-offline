//
//  PACKET_ZC_ALL_ACH_LIST.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

/// See `clif_achievement_list_all`
public struct PACKET_ZC_ALL_ACH_LIST: DecodablePacket {
    public static var packetType: Int16 {
        0xa23
    }

    public var packetLength: Int16 {
        -1
    }

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        // TODO: To be implemented.
        _ = try decoder.decode([UInt8].self, length: Int(packetLength - 4))
    }
}
