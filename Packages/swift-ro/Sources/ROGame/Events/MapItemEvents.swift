//
//  MapItemEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/1.
//

import RONetwork

public enum MapItemEvents {
    public struct Spawned: Event {
        public let item: MapItem

        init(packet: PACKET_ZC_ITEM_ENTRY) {
            self.item = MapItem(packet: packet)
        }

        init(packet: packet_dropflooritem) {
            self.item = MapItem(packet: packet)
        }
    }

    public struct Vanished: Event {
        public let objectID: UInt32

        init(packet: PACKET_ZC_ITEM_DISAPPEAR) {
            self.objectID = packet.itemAid
        }
    }
}
