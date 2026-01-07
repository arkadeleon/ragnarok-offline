//
//  MapObjectEvents.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/9/25.
//

import RagnarokConstants
import RagnarokModels

public enum MapObjectEvents {
    public struct Spawned: Event {
        public let object: MapObject
        public let position: SIMD2<Int>
        public let direction: Direction
        public let headDirection: HeadDirection
    }

    public struct Moved: Event {
        public let object: MapObject
        public let startPosition: SIMD2<Int>
        public let endPosition: SIMD2<Int>
    }

    public struct Stopped: Event {
        public let objectID: UInt32
        public let position: SIMD2<Int>
    }

    public struct Vanished: Event {
        public let objectID: UInt32
    }

    public struct DirectionChanged: Event {
        public let objectID: UInt32
        public let direction: Direction
        public let headDirection: HeadDirection
    }

    public struct SpriteChanged: Event {
        public let objectID: UInt32
    }

    public struct StateChanged: Event {
        public let objectID: UInt32
        public let bodyState: StatusChangeOption1
        public let healthState: StatusChangeOption2
        public let effectState: StatusChangeOption
    }

    public struct ActionPerformed: Event {
        public let sourceObjectID: UInt32
        public let targetObjectID: UInt32
        public let actionType: DamageType
    }
}
