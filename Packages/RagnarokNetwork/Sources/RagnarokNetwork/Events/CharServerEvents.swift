//
//  CharServerEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/9/25.
//

import RagnarokModels

public enum CharServerEvents {
    public struct Accepted: Event {
        public let characters: [CharacterInfo]
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
