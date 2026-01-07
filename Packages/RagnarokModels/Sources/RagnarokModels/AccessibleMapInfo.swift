//
//  AccessibleMapInfo.swift
//  RagnarokModels
//
//  Created by Leon Li on 2025/6/30.
//

import RagnarokPackets

public struct AccessibleMapInfo: Sendable {
    public let status: Int32
    public let mapName: String

    public init(from map: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME_sub) {
        self.status = map.status
        self.mapName = map.map
    }
}
