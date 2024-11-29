//
//  ObjectEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

public enum ObjectEvents {
    public struct DirectionChanged: Event {
        public let sourceID: UInt32
        public let headDirection: UInt16
        public let direction: UInt8
    }

    public struct MessageDisplay: Event {
        public let message: String
    }

    public struct Moved: Event {
        public let id: UInt32
        public let moveData: MoveData
    }

    public struct Spawned: Event {
        public let id: UInt32
        public let job: Int16
        public let name: String
    }

    public struct SpriteChanged: Event {
        public let id: UInt32
    }

    public struct StateChanged: Event {
        public let id: UInt32
    }

    public struct Vanished: Event {
        public let id: UInt32
    }
}
