//
//  BlockEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

public enum BlockEvents {
    public struct DirectionChanged: Event {
        public var sourceID: UInt32
        public let headDirection: UInt16
        public let direction: UInt8
    }

    public struct SpriteChanged: Event {
    }
}
