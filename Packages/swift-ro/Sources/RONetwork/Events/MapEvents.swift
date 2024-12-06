//
//  MapEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/26.
//

import ROGenerated

public enum MapEvents {
    public struct Changed: Event {
        public let mapName: String
        public let position: SIMD2<Int16>

        init(packet: PACKET_ZC_NPCACK_MAPMOVE) {
            self.mapName = packet.mapName
            self.position = [
                Int16(packet.xPos),
                Int16(packet.yPos),
            ]
        }
    }
}
