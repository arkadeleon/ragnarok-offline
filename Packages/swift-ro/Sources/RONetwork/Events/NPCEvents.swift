//
//  NPCEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/6.
//

import ROPackets

public enum NPCEvents {
    public struct DialogReceived: Event {
        public let dialog: NPCDialog
    }

    public struct DialogClosed: Event {
        public let npcID: UInt32
    }

    public struct ImageReceived: Event {
        public let image: String

        init(packet: PACKET_ZC_SHOW_IMAGE) {
            self.image = packet.image
        }
    }

    public struct MinimapMarkPositionReceived: Event {
        public let npcID: UInt32
        public let position: SIMD2<Int>

        init(packet: PACKET_ZC_COMPASS) {
            self.npcID = packet.npcId
            self.position = SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))
        }
    }
}
