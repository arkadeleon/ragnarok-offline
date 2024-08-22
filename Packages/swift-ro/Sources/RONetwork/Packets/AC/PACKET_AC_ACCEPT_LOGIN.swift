//
//  PACKET_AC_ACCEPT_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

public struct PACKET_AC_ACCEPT_LOGIN: DecodablePacket {
    public static var packetType: Int16 {
        if PACKET_VERSION >= 20170315 {
            0xac4
        } else {
            0x69
        }
    }

    public var packetLength: Int16 {
        if PACKET_VERSION >= 20170315 {
            2 + 2 + 4 + 4 + 4 + 4 + 26 + 1 + 17 + ServerInfo.size * Int16(serverList.count)
        } else {
            2 + 2 + 4 + 4 + 4 + 4 + 26 + 1 + ServerInfo.size * Int16(serverList.count)
        }
    }

    public var authCode: UInt32
    public var aid: UInt32
    public var userLevel: UInt32
    public var lastLoginIP: UInt32
    public var lastLoginTime: String
    public var sex: UInt8
    public var token: [UInt8]
    public var serverList: [ServerInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)
        let serverCount = (packetLength - 2 - 2 - 4 - 4 - 4 - 4 - 26 - 1) / ServerInfo.size

        authCode = try decoder.decode(UInt32.self)
        aid = try decoder.decode(UInt32.self)
        userLevel = try decoder.decode(UInt32.self)
        lastLoginIP = try decoder.decode(UInt32.self)
        lastLoginTime = try decoder.decode(String.self, length: 26)
        sex = try decoder.decode(UInt8.self)

        if PACKET_VERSION >= 20170315 {
            token = try decoder.decode([UInt8].self, length: 17)
        } else {
            token = []
        }

        serverList = []
        for _ in 0..<serverCount {
            let serverInfo = try decoder.decode(ServerInfo.self)
            serverList.append(serverInfo)
        }
    }
}
