//
//  PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/9.
//

import BinaryIO

/// See `chclif_accessible_maps`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME: DecodablePacket {
    public static var packetType: Int16 {
        0x840
    }

    public var packetLength: Int16 {
        -1
    }

    public var accessibleMaps: [_AccessibleMapInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        let accessibleMapCount = (packetLength - 4) / _AccessibleMapInfo.decodedLength

        accessibleMaps = []
        for _ in 0..<accessibleMapCount {
            let accessibleMap = try _AccessibleMapInfo(from: decoder)
            accessibleMaps.append(accessibleMap)
        }
    }
}
