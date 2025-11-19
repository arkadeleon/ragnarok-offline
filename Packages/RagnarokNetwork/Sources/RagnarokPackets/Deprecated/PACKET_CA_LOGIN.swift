//
//  PACKET_CA_LOGIN.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2021/7/5.
//

import BinaryIO

/// See `logclif_parse_reqauth_raw`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_CA_LOGIN: _EncodablePacket {
    public var packetType: Int16 {
        0x64
    }

    public var packetLength: Int16 {
        2 + 4 + 24 + 24 + 1
    }

    public var version: UInt32
    public var username: String
    public var password: String
    public var clientType: UInt8

    public init() {
        version = 0
        username = ""
        password = ""
        clientType = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(version)
        try encoder.encode(username, lengthOfBytes: 24)
        try encoder.encode(password, lengthOfBytes: 24)
        try encoder.encode(clientType)
    }
}
