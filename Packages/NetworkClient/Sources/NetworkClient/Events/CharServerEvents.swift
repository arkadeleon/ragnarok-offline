//
//  CharServerEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import NetworkPackets

public enum CharServerEvents {
    public struct Accepted: Event {
        public let chars: [CharInfo]
    }

    public struct Refused: Event {
    }

    public struct NotifyMapServer: Event {
        public let charID: UInt32
        public let mapName: String
        public let mapServer: MapServerInfo
    }

    public struct NotifyAccessibleMaps: Event {
        public let accessibleMaps: [AccessibleMapInfo]
    }
}
