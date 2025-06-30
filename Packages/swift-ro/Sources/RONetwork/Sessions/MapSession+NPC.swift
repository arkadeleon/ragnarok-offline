//
//  MapSession+NPC.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/29.
//

import ROPackets

extension MapSession {
    func subscribeToNPCPackets(with subscription: inout ClientSubscription) {
        // See `clif_scriptmes`
        subscription.subscribe(to: PACKET_ZC_SAY_DIALOG.self) { [unowned self] packet in
            if let dialog = self.pendingNPCDialog,
               dialog.objectID == packet.NpcID,
               case .message(var message, let hasNextMessage) = dialog.content {
                message.append("\n")
                message.append(packet.message)
                let dialog = NPCDialog(objectID: packet.NpcID, content: .message(message: message, hasNextMessage: hasNextMessage))
                self.pendingNPCDialog = dialog
            } else {
                let dialog = NPCDialog(objectID: packet.NpcID, content: .message(message: packet.message, hasNextMessage: nil))
                self.pendingNPCDialog = dialog
            }
        }

        // See `clif_scriptnext`
        subscription.subscribe(to: PACKET_ZC_WAIT_DIALOG.self) { [unowned self] packet in
            if let dialog = self.pendingNPCDialog,
               dialog.objectID == packet.NpcID,
               case .message(let message, _) = dialog.content {
                let dialog = NPCDialog(objectID: dialog.objectID, content: .message(message: message, hasNextMessage: true))
                let event = NPCEvents.DialogReceived(dialog: dialog)
                self.postEvent(event)

                self.pendingNPCDialog = nil
            }
        }

        // See `clif_scriptclose`
        subscription.subscribe(to: PACKET_ZC_CLOSE_DIALOG.self) { [unowned self] packet in
            if let dialog = self.pendingNPCDialog,
               dialog.objectID == packet.npcId,
               case .message(let message, _) = dialog.content {
                let dialog = NPCDialog(objectID: dialog.objectID, content: .message(message: message, hasNextMessage: false))
                let event = NPCEvents.DialogReceived(dialog: dialog)
                self.postEvent(event)

                self.pendingNPCDialog = nil
            }
        }

        // See `clif_scriptclear`
        subscription.subscribe(to: PACKET_ZC_CLEAR_DIALOG.self) { [unowned self] packet in
            let event = NPCEvents.DialogClosed(npcID: packet.GID)
            self.postEvent(event)
        }

        // See `clif_scriptmenu`
        subscription.subscribe(to: PACKET_ZC_MENU_LIST.self) { [unowned self] packet in
            let menu = packet.menu.split(separator: ":").map(String.init)
            let dialog = NPCDialog(objectID: packet.npcId, content: .menu(menu: menu))
            let event = NPCEvents.DialogReceived(dialog: dialog)
            self.postEvent(event)
        }

        // See `clif_scriptinput`
        subscription.subscribe(to: PACKET_ZC_OPEN_EDITDLG.self) { [unowned self] packet in
            let dialog = NPCDialog(objectID: packet.npcId, content: .numberInput)
            let event = NPCEvents.DialogReceived(dialog: dialog)
            self.postEvent(event)
        }

        // See `clif_scriptinputstr`
        subscription.subscribe(to: PACKET_ZC_OPEN_EDITDLGSTR.self) { [unowned self] packet in
            let dialog = NPCDialog(objectID: packet.npcId, content: .textInput)
            let event = NPCEvents.DialogReceived(dialog: dialog)
            self.postEvent(event)
        }

        // See `clif_cutin`
        subscription.subscribe(to: PACKET_ZC_SHOW_IMAGE.self) { [unowned self] packet in
            let event = NPCEvents.ImageReceived(image: packet.image)
            self.postEvent(event)
        }

        // See `clif_viewpoint`
        subscription.subscribe(to: PACKET_ZC_COMPASS.self) { [unowned self] packet in
            let event = NPCEvents.MinimapMarkPositionReceived(
                npcID: packet.npcId,
                position: SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))
            )
            self.postEvent(event)
        }
    }

    // See `clif_parse_NpcClicked`
    public func talkToNPC(objectID: UInt32) {
        var packet = PACKET_CZ_CONTACTNPC()
        packet.packetType = HEADER_CZ_CONTACTNPC
        packet.AID = objectID
        packet.type = 1

        client.sendPacket(packet)
    }

    // See `clif_parse_NpcNextClicked`
    public func requestNextMessage(objectID: UInt32) {
        var packet = PACKET_CZ_REQ_NEXT_SCRIPT()
        packet.packetType = HEADER_CZ_REQ_NEXT_SCRIPT
        packet.npcID = objectID

        client.sendPacket(packet)
    }

    // See `clif_parse_NpcCloseClicked`
    public func closeDialog(objectID: UInt32) {
        var packet = PACKET_CZ_CLOSE_DIALOG()
        packet.packetType = HEADER_CZ_CLOSE_DIALOG
        packet.GID = objectID

        client.sendPacket(packet)
    }

    // See `clif_parse_NpcSelectMenu`
    public func selectMenu(objectID: UInt32, select: UInt8) {
        var packet = PACKET_CZ_CHOOSE_MENU()
        packet.packetType = HEADER_CZ_CHOOSE_MENU
        packet.npcID = objectID
        packet.select = select

        client.sendPacket(packet)
    }

    // See `clif_parse_NpcAmountInput`
    public func inputNumber(objectID: UInt32, value: Int32) {
    }

    // See `clif_parse_NpcStringInput`
    public func inputText(objectID: UInt32, value: String) {
    }
}
