//
//  MapObjectEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROConstants
import RONetwork

public enum MapObjectEvents {
    public struct DirectionChanged: Event {
        public let objectID: UInt32
        public let headDirection: UInt16
        public let direction: UInt8

        init(packet: PACKET_ZC_CHANGE_DIRECTION) {
            self.objectID = packet.srcId
            self.headDirection = packet.headDir
            self.direction = packet.dir
        }
    }

    public struct MessageReceived: Event {
        public let message: String
    }

    public struct Moved: Event {
        public let object: MapObject
        public let fromPosition: SIMD2<Int16>
        public let toPosition: SIMD2<Int16>
    }

    public struct Stopped: Event {
        public let objectID: UInt32
        public let position: SIMD2<Int16>
    }

    public struct Spawned: Event {
        public let object: MapObject
    }

    public struct SpriteChanged: Event {
        public let objectID: UInt32
    }

    public struct StateChanged: Event {
        public let objectID: UInt32
        public let bodyState: StatusChangeOption1
        public let healthState: StatusChangeOption2
        public let effectState: StatusChangeOption

        init(packet: PACKET_ZC_STATE_CHANGE) {
            objectID = packet.AID
            bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
            healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
            effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
        }
    }

    public struct Vanished: Event {
        public let objectID: UInt32
    }
}
