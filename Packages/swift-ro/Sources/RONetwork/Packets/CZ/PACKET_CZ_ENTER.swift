//
//  PACKET_CZ_ENTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

/// See `clif_parse_WantToConnection`
public struct PACKET_CZ_ENTER: EncodablePacket {
    public var packetType: Int16 {
        packetDatabase.entryForEnter.packetType
    }

    public var packetLength: Int16 {
        packetDatabase.entryForEnter.packetLength
    }

    public var aid: UInt32
    public var gid: UInt32
    public var authCode: UInt32
    public var clientTime: UInt32
    public var sex: UInt8

    public init() {
        aid = 0
        gid = 0
        authCode = 0
        clientTime = 0
        sex = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let offsets = packetDatabase.entryForEnter.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: aid)
        data.replaceSubrange(from: offsets[1], with: gid)
        data.replaceSubrange(from: offsets[2], with: authCode)
        data.replaceSubrange(from: offsets[3], with: clientTime)
        data.replaceSubrange(from: offsets[4], with: sex)

        try encoder.encode(data)
    }
}

extension PacketDatabase {
    var entryForEnter: Entry {
        entry(forFunctionName: "clif_parse_WantToConnection")!
    }
}
