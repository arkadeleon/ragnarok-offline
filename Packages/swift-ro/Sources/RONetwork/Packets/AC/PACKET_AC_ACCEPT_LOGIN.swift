//
//  PACKET_AC_ACCEPT_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

/// See `logclif_auth_ok`
public struct PACKET_AC_ACCEPT_LOGIN: DecodablePacket {
    public static var packetType: Int16 {
        if PACKET_VERSION >= 20170315 {
            0xac4
        } else {
            0x69
        }
    }

    public var packetLength: Int16 {
        -1
    }

    public var loginID1: UInt32
    public var accountID: UInt32
    public var loginID2: UInt32
    public var lastLoginIP: UInt32
    public var lastLoginTime: String
    public var sex: UInt8
    public var token: [UInt8]
    public var charServers: [CharServerInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        let charServerCount: Int16
        if PACKET_VERSION >= 20170315 {
            charServerCount = (packetLength - 64) / CharServerInfo.decodedLength
        } else {
            charServerCount = (packetLength - 47) / CharServerInfo.decodedLength
        }

        loginID1 = try decoder.decode(UInt32.self)
        accountID = try decoder.decode(UInt32.self)
        loginID2 = try decoder.decode(UInt32.self)
        lastLoginIP = try decoder.decode(UInt32.self)
        lastLoginTime = try decoder.decode(String.self, length: 26)
        sex = try decoder.decode(UInt8.self)

        if PACKET_VERSION >= 20170315 {
            token = try decoder.decode([UInt8].self, length: 17)
        } else {
            token = []
        }

        charServers = []
        for _ in 0..<charServerCount {
            let charServer = try decoder.decode(CharServerInfo.self)
            charServers.append(charServer)
        }
    }
}
