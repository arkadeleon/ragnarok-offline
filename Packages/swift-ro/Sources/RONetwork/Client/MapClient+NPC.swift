//
//  MapClient+NPC.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/29.
//

import ROGenerated

extension MapClient {
    func registerNPCPackets() {
        // See `clif_scriptmes`
        registerPacket(PACKET_ZC_SAY_DIALOG.self, for: HEADER_ZC_SAY_DIALOG) { packet in
        }

        // See `clif_scriptnext`
        registerPacket(PACKET_ZC_WAIT_DIALOG.self, for: HEADER_ZC_WAIT_DIALOG) { packet in
        }

        // See `clif_scriptclose`
        registerPacket(PACKET_ZC_CLOSE_DIALOG.self, for: HEADER_ZC_CLOSE_DIALOG) { packet in
        }

        // See `clif_cutin`
        registerPacket(PACKET_ZC_SHOW_IMAGE.self, for: HEADER_ZC_SHOW_IMAGE) { packet in
        }
    }

    public func contactNPC(npcID: UInt32) {
        var packet = PACKET_CZ_CONTACTNPC()
        packet.packetType = HEADER_CZ_CONTACTNPC
        packet.AID = npcID
        packet.type = 1

        sendPacket(packet)
    }

    public func requestNextScript(npcID: UInt32) {
        var packet = PACKET_CZ_REQ_NEXT_SCRIPT()
        packet.packetType = HEADER_CZ_REQ_NEXT_SCRIPT
        packet.npcID = npcID

        sendPacket(packet)
    }

    // See `clif_parse_NpcCloseClicked`
    public func closeDialog(npcID: UInt32) {
        var packet = PACKET_CZ_CLOSE_DIALOG()
        packet.packetType = HEADER_CZ_CLOSE_DIALOG
        packet.npcID = npcID

        sendPacket(packet)
    }
}
