//
//  AccessibleMapInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/30.
//

import ROPackets

public struct AccessibleMapInfo: Sendable {
    public let status: Int32
    public let mapName: String

    init(map: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME_sub) {
        self.status = map.status
        self.mapName = map.map
    }
}
