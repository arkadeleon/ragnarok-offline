//
//  MapSession+MapItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/2.
//

import ROPackets

extension MapSession {
    func subscribeToMapItemPackets(with subscription: inout ClientSubscription) {
        subscription.subscribe(to: PACKET_ZC_ITEM_ENTRY.self) { [unowned self] packet in
            let event = MapItemEvents.Spawned(packet: packet)
            self.postEvent(event)
        }

        subscription.subscribe(to: packet_dropflooritem.self) { [unowned self] packet in
            let event = MapItemEvents.Spawned(packet: packet)
            self.postEvent(event)
        }

        subscription.subscribe(to: PACKET_ZC_ITEM_DISAPPEAR.self) { [unowned self] packet in
            let event = MapItemEvents.Vanished(packet: packet)
            self.postEvent(event)
        }
    }

    public func pickUpItem(objectID: UInt32) {
        var packet = PACKET_CZ_ITEM_PICKUP()
        packet.itemAID = objectID

        client.sendPacket(packet)
    }
}
