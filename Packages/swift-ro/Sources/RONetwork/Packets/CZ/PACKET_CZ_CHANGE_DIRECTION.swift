//
//  PACKET_CZ_CHANGE_DIRECTION.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

/// See `clif_parse_ChangeDir`
public struct PACKET_CZ_CHANGE_DIRECTION: EncodablePacket {
    public var packetType: Int16 {
        packetDatabase.entryForChangeDirection.packetType
    }

    public var packetLength: Int16 {
        packetDatabase.entryForChangeDirection.packetLength
    }

    public var headDirection: UInt16
    public var direction: UInt8

    public init() {
        headDirection = 0
        direction = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let offsets = packetDatabase.entryForChangeDirection.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: headDirection)
        data.replaceSubrange(from: offsets[1], with: direction)

        try encoder.encode(data)
    }
}

extension PacketDatabase {
    var entryForChangeDirection: Entry {
        entry(forFunctionName: "clif_parse_ChangeDir")!
    }
}
