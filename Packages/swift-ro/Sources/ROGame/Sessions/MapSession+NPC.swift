//
//  MapSession+NPC.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/29.
//

import RONetwork

extension MapSession {
    func subscribeToNPCPackets(with subscription: inout ClientSubscription) {
        // See `clif_scriptmes`
        subscription.subscribe(to: PACKET_ZC_SAY_DIALOG.self) { [unowned self] packet in
            await self.storage.updateNPCDialog(with: packet)
        }

        // See `clif_scriptnext`
        subscription.subscribe(to: PACKET_ZC_WAIT_DIALOG.self) { [unowned self] packet in
            let dialog = await self.storage.updateNPCDialog(with: packet)

            if let dialog {
                let event = NPCEvents.DialogUpdated(dialog: dialog)
                self.postEvent(event)
            }
        }

        // See `clif_scriptclose`
        subscription.subscribe(to: PACKET_ZC_CLOSE_DIALOG.self) { [unowned self] packet in
            let dialog = await self.storage.updateNPCDialog(with: packet)

            if let dialog {
                let event = NPCEvents.DialogUpdated(dialog: dialog)
                self.postEvent(event)
            }
        }

        // See `clif_scriptclear`
        subscription.subscribe(to: PACKET_ZC_CLEAR_DIALOG.self) { [unowned self] packet in
            let event = NPCEvents.DialogClosed(npcID: packet.GID)
            self.postEvent(event)
        }

        // See `clif_scriptmenu`
        subscription.subscribe(to: PACKET_ZC_MENU_LIST.self) { [unowned self] packet in
            let dialog = await self.storage.updateNPCDialog(with: packet)

            let event = NPCEvents.DialogUpdated(dialog: dialog)
            self.postEvent(event)
        }

        // See `clif_scriptinput`
        subscription.subscribe(to: PACKET_ZC_OPEN_EDITDLG.self) { [unowned self] packet in
            let dialog = await self.storage.updateNPCDialog(with: packet)

            let event = NPCEvents.DialogUpdated(dialog: dialog)
            self.postEvent(event)
        }

        // See `clif_scriptinputstr`
        subscription.subscribe(to: PACKET_ZC_OPEN_EDITDLGSTR.self) { [unowned self] packet in
            let dialog = await self.storage.updateNPCDialog(with: packet)

            let event = NPCEvents.DialogUpdated(dialog: dialog)
            self.postEvent(event)
        }

        // See `clif_cutin`
        subscription.subscribe(to: PACKET_ZC_SHOW_IMAGE.self) { [unowned self] packet in
            let event = NPCEvents.ImageReceived(packet: packet)
            self.postEvent(event)
        }

        // See `clif_viewpoint`
        subscription.subscribe(to: PACKET_ZC_COMPASS.self) { [unowned self] packet in
            let event = NPCEvents.MinimapMarkPositionReceived(packet: packet)
            self.postEvent(event)
        }
    }

    // See `clif_parse_NpcClicked`
    public func talkToNPC(npcID: UInt32) {
        var packet = PACKET_CZ_CONTACTNPC()
        packet.packetType = HEADER_CZ_CONTACTNPC
        packet.AID = npcID
        packet.type = 1

        client.sendPacket(packet)
    }

    // See `clif_parse_NpcNextClicked`
    public func requestNextMessage(npcID: UInt32) {
        Task {
            await storage.closeNPCDialog()

            let event = NPCEvents.DialogClosed(npcID: npcID)
            postEvent(event)

            var packet = PACKET_CZ_REQ_NEXT_SCRIPT()
            packet.packetType = HEADER_CZ_REQ_NEXT_SCRIPT
            packet.npcID = npcID

            client.sendPacket(packet)
        }
    }

    // See `clif_parse_NpcCloseClicked`
    public func closeDialog(npcID: UInt32) {
        Task {
            await storage.closeNPCDialog()

            let event = NPCEvents.DialogClosed(npcID: npcID)
            postEvent(event)

            var packet = PACKET_CZ_CLOSE_DIALOG()
            packet.packetType = HEADER_CZ_CLOSE_DIALOG
            packet.GID = npcID

            client.sendPacket(packet)
        }
    }

    // See `clif_parse_NpcSelectMenu`
    public func selectMenu(npcID: UInt32, select: UInt8) {
        Task {
            await storage.closeNPCDialog()

            let event = NPCEvents.DialogClosed(npcID: npcID)
            postEvent(event)

            var packet = PACKET_CZ_CHOOSE_MENU()
            packet.packetType = HEADER_CZ_CHOOSE_MENU
            packet.npcID = npcID
            packet.select = select

            client.sendPacket(packet)
        }
    }

    // See `clif_parse_NpcAmountInput`
    public func inputNumber(npcID: UInt32, value: Int32) {
        Task {
            await storage.closeNPCDialog()

            let event = NPCEvents.DialogClosed(npcID: npcID)
            postEvent(event)
        }
    }

    // See `clif_parse_NpcStringInput`
    public func inputText(npcID: UInt32, value: String) {
        Task {
            await storage.closeNPCDialog()

            let event = NPCEvents.DialogClosed(npcID: npcID)
            postEvent(event)
        }
    }
}
