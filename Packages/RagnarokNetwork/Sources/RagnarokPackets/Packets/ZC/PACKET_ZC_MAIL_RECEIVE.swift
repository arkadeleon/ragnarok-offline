//
//  PACKET_ZC_MAIL_RECEIVE.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/28.
//

import BinaryIO

public let HEADER_ZC_MAIL_RECEIVE: Int16 = 0x24a

/// See `clif_Mail_new`
public struct PACKET_ZC_MAIL_RECEIVE: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var mailID: UInt32
    public var title: String
    public var sender: String

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        mailID = try decoder.decode(UInt32.self)
        title = try decoder.decode(String.self, lengthOfBytes: 40)
        sender = try decoder.decode(String.self, lengthOfBytes: 24)
    }
}
