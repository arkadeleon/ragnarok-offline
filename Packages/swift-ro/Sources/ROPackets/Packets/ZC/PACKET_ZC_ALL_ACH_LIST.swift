//
//  PACKET_ZC_ALL_ACH_LIST.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import ROCore

/// See `clif_achievement_list_all`
public struct PACKET_ZC_ALL_ACH_LIST: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var packetLength: Int16

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        packetLength = try decoder.decode(Int16.self)

        // TODO: To be implemented.
        _ = try decoder.decode([UInt8].self, count: Int(packetLength - 4))
    }
}
