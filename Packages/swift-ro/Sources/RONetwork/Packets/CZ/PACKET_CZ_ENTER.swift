//
//  PACKET_CZ_ENTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

/// See `clif_parse_WantToConnection`
public struct PACKET_CZ_ENTER: EncodablePacket {
    static let entry = packetDatabase.entries(forFunctionName: "clif_parse_WantToConnection")[0]

    public static var packetType: Int16 {
        entry.packetType
    }

    public var packetLength: Int16 {
        Self.entry.packetLength
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
        let packetLength = Int(packetLength)
        let offsets = Self.entry.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))

        data.replaceSubrange(
            0..<2,
            with: withUnsafeBytes(of: packetType, [UInt8].init)
        )

        data.replaceSubrange(
            offsets[0]..<(offsets[0] + 4),
            with: withUnsafeBytes(of: aid, [UInt8].init)
        )

        data.replaceSubrange(
            offsets[1]..<(offsets[1] + 4),
            with: withUnsafeBytes(of: gid, [UInt8].init)
        )

        data.replaceSubrange(
            offsets[2]..<(offsets[2] + 4),
            with: withUnsafeBytes(of: authCode, [UInt8].init)
        )

        data.replaceSubrange(
            offsets[3]..<(offsets[3] + 4),
            with: withUnsafeBytes(of: clientTime, [UInt8].init)
        )

        data[offsets[4]] = sex

        try encoder.encode(data)
    }
}
