//
//  PACKET_CZ_REQUEST_TIME.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/23.
//

/// See `clif_parse_TickSend`
public struct PACKET_CZ_REQUEST_TIME: EncodablePacket {
    public var packetType: Int16 {
        packetDatabase.entryForRequestTime.packetType
    }

    public var packetLength: Int16 {
        packetDatabase.entryForRequestTime.packetLength
    }

    public var clientTime: UInt32

    public init() {
        clientTime = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let offsets = packetDatabase.entryForRequestTime.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: clientTime)

        try encoder.encode(data)
    }
}

extension PacketDatabase {
    var entryForRequestTime: Entry {
        entry(forFunctionName: "clif_parse_TickSend")!
    }
}
