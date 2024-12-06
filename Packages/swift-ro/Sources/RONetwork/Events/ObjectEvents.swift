//
//  ObjectEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/25.
//

import ROGenerated

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
        public let position: SIMD2<Int16>

        init(packet: packet_spawn_unit) {
            id = packet.AID
            job = packet.job
            name = packet.name

            let posDir = PosDir(data: packet.PosDir)
            position = [posDir.x, posDir.y]
        }

        init(packet: packet_idle_unit) {
            id = packet.AID
            job = packet.job
            name = packet.name

            let posDir = PosDir(data: packet.PosDir)
            position = [posDir.x, posDir.y]
        }
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
