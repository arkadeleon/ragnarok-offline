//
//  NPCEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/6.
//

import RONetwork

public enum NPCEvents {
    public struct DialogUpdated: Event {
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
        public let position: SIMD2<Int16>

        init(packet: PACKET_ZC_COMPASS) {
            self.npcID = packet.npcId
            self.position = [
                Int16(packet.xPos),
                Int16(packet.yPos),
            ]
        }
    }
}
