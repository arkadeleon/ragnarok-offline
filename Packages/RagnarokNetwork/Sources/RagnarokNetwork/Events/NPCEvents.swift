//
//  NPCEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/12/6.
//

public enum NPCEvents {
    public struct DialogReceived: Event {
        public let npcID: UInt32
    }

    public struct DialogClosed: Event {
        public let npcID: UInt32
    }

    public struct ImageReceived: Event {
        public let image: String
    }

    public struct MinimapMarkPositionReceived: Event {
        public let npcID: UInt32
        public let position: SIMD2<Int>
    }
}
