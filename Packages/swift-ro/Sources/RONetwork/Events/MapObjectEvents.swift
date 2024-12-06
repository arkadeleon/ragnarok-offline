//
//  MapObjectEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROGenerated

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

    public struct MessageDisplay: Event {
        public let message: String

        init(packet: PACKET_ZC_NPC_CHAT) {
            self.message = packet.message
        }
    }

    public struct Moved: Event {
        public let object: MapObject
        public let fromPosition: SIMD2<Int16>
        public let toPosition: SIMD2<Int16>

        init(packet: packet_unit_walking) {
            self.object = MapObject(packet: packet)

            let moveData = MoveData(data: packet.MoveData)
            self.fromPosition = [moveData.x0, moveData.y0]
            self.toPosition = [moveData.x1, moveData.y1]
        }
    }

    public struct Spawned: Event {
        public let object: MapObject
        public let position: SIMD2<Int16>

        init(packet: packet_spawn_unit) {
            self.object = MapObject(packet: packet)

            let posDir = PosDir(data: packet.PosDir)
            self.position = [posDir.x, posDir.y]
        }

        init(packet: packet_idle_unit) {
            self.object = MapObject(packet: packet)

            let posDir = PosDir(data: packet.PosDir)
            self.position = [posDir.x, posDir.y]
        }
    }

    public struct SpriteChanged: Event {
        public let objectID: UInt32

        init(packet: PACKET_ZC_SPRITE_CHANGE) {
            self.objectID = packet.AID
        }
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

    public struct Vanished: Event {
        public let objectID: UInt32

        init(packet: PACKET_ZC_NOTIFY_VANISH) {
            self.objectID = packet.gid
        }
    }
}
