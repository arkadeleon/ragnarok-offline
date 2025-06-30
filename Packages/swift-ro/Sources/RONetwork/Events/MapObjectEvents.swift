//
//  MapObjectEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROConstants
import ROPackets

public enum MapObjectEvents {
    public struct Spawned: Event {
        public let object: MapObject
        public let position: SIMD2<Int>
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
        public let headDirection: UInt16
        public let direction: UInt8

        init(packet: PACKET_ZC_CHANGE_DIRECTION) {
            self.objectID = packet.srcId
            self.headDirection = packet.headDir
            self.direction = packet.dir
        }
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
            self.objectID = packet.AID
            self.bodyState = StatusChangeOption1(rawValue: Int(packet.bodyState)) ?? .none
            self.healthState = StatusChangeOption2(rawValue: Int(packet.healthState)) ?? .none
            self.effectState = StatusChangeOption(rawValue: Int(packet.effectState)) ?? .nothing
        }
    }

    public struct ActionPerformed: Event {
        public let sourceObjectID: UInt32
        public let targetObjectID: UInt32
        public let actionType: DamageType

        init(packet: PACKET_ZC_NOTIFY_ACT) {
            self.sourceObjectID = UInt32(packet.srcID)
            self.targetObjectID = UInt32(packet.targetID)
            self.actionType = DamageType(rawValue: Int(packet.type)) ?? .normal
        }
    }
}
