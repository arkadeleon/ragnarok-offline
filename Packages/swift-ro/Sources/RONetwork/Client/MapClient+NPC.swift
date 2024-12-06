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
        registerPacket(PACKET_ZC_SAY_DIALOG.self, for: HEADER_ZC_SAY_DIALOG) { [unowned self] packet in
            let event = NPCEvents.DisplayDialog(packet: packet)
            self.postEvent(event)
        }

        // See `clif_scriptnext`
        registerPacket(PACKET_ZC_WAIT_DIALOG.self, for: HEADER_ZC_WAIT_DIALOG) { [unowned self] packet in
            let event = NPCEvents.AddNextButton(packet: packet)
            self.postEvent(event)
        }

        // See `clif_scriptclose`
        registerPacket(PACKET_ZC_CLOSE_DIALOG.self, for: HEADER_ZC_CLOSE_DIALOG) { [unowned self] packet in
            let event = NPCEvents.AddCloseButton(packet: packet)
            self.postEvent(event)
        }

        // See `clif_scriptclear`
        registerPacket(PACKET_ZC_CLEAR_DIALOG.self, for: HEADER_ZC_CLEAR_DIALOG) { [unowned self] packet in
            let event = NPCEvents.CloseDialog(packet: packet)
            self.postEvent(event)
        }

        // See `clif_scriptmenu`
        registerPacket(PACKET_ZC_MENU_LIST.self, for: HEADER_ZC_MENU_LIST) { [unowned self] packet in
            let event = NPCEvents.DisplayMenuDialog(packet: packet)
            self.postEvent(event)
        }

        // See `clif_scriptinput`
        registerPacket(PACKET_ZC_OPEN_EDITDLG.self, for: HEADER_ZC_OPEN_EDITDLG) { [unowned self] packet in
            let event = NPCEvents.DisplayNumberInputDialog(packet: packet)
            self.postEvent(event)
        }

        // See `clif_scriptinputstr`
        registerPacket(PACKET_ZC_OPEN_EDITDLGSTR.self, for: HEADER_ZC_OPEN_EDITDLGSTR) { [unowned self] packet in
            let event = NPCEvents.DisplayTextInputDialog(packet: packet)
            self.postEvent(event)
        }

        // See `clif_cutin`
        registerPacket(PACKET_ZC_SHOW_IMAGE.self, for: HEADER_ZC_SHOW_IMAGE) { [unowned self] packet in
            let event = NPCEvents.DisplayImage(packet: packet)
            self.postEvent(event)
        }

        // See `clif_viewpoint`
        registerPacket(PACKET_ZC_COMPASS.self, for: HEADER_ZC_COMPASS) { [unowned self] packet in
            let event = NPCEvents.MarkPosition(packet: packet)
            self.postEvent(event)
        }
    }

    // See `clif_parse_NpcClicked`
    public func contactNPC(npcID: UInt32) {
        var packet = PACKET_CZ_CONTACTNPC()
        packet.packetType = HEADER_CZ_CONTACTNPC
        packet.AID = npcID
        packet.type = 1

        sendPacket(packet)
    }

    // See `clif_parse_NpcNextClicked`
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

    // See `clif_parse_NpcSelectMenu`
    public func selectMenu(npcID: UInt32, select: UInt8) {
        var packet = PACKET_CZ_CHOOSE_MENU()
        packet.packetType = HEADER_CZ_CHOOSE_MENU
        packet.npcID = npcID
        packet.select = select

        sendPacket(packet)
    }

    // See `clif_parse_NpcAmountInput`
    public func inputNumber(npcID: UInt32, value: Int32) {
    }

    // See `clif_parse_NpcStringInput`
    public func inputText(npcID: UInt32, value: String) {
    }
}
