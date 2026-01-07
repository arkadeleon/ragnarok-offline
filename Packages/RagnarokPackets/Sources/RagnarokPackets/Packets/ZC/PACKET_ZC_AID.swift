//
//  PACKET_ZC_AID.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/22.
//

import BinaryIO

public let HEADER_ZC_AID: Int16 = 0x283

public struct PACKET_ZC_AID: DecodablePacket {
    public var packetType: Int16
    public var accountID: UInt32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        accountID = try decoder.decode(UInt32.self)
    }
}
