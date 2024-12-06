//
//  ObjectEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROGenerated

public enum ObjectEvents {
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
        public let objectID: UInt32
        public let fromPosition: SIMD2<Int16>
        public let toPosition: SIMD2<Int16>

        init(packet: packet_unit_walking) {
            self.objectID = packet.AID

            let moveData = MoveData(data: packet.MoveData)
            self.fromPosition = [moveData.x0, moveData.y0]
            self.toPosition = [moveData.x1, moveData.y1]
        }
    }

    public struct Spawned: Event {
        public let objectID: UInt32
        public let job: Int16
        public let name: String
        public let position: SIMD2<Int16>

        init(packet: packet_spawn_unit) {
            self.objectID = packet.AID
            self.job = packet.job
            self.name = packet.name

            let posDir = PosDir(data: packet.PosDir)
            self.position = [posDir.x, posDir.y]
        }

        init(packet: packet_idle_unit) {
            self.objectID = packet.AID
            self.job = packet.job
            self.name = packet.name

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

        init(packet: PACKET_ZC_STATE_CHANGE) {
            self.objectID = packet.AID
        }
    }

    public struct Vanished: Event {
        public let objectID: UInt32

        init(packet: PACKET_ZC_NOTIFY_VANISH) {
            self.objectID = packet.gid
        }
    }
}
