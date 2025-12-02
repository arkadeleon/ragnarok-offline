//
//  MapSession+NPC.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/11/29.
//

import RagnarokPackets

extension MapSession {
    func subscribeToNPCPackets(with subscription: inout ClientSubscription) {
        // See `clif_scriptmes`
        subscription.subscribe(to: PACKET_ZC_SAY_DIALOG.self) { [unowned self] packet in
            let event = MapSession.Event.npcDialogMessageReceived(npcID: packet.NpcID, message: packet.message)
            self.postEvent(event)
        }

        // See `clif_scriptnext`
        subscription.subscribe(to: PACKET_ZC_WAIT_DIALOG.self) { [unowned self] packet in
            let event = MapSession.Event.npcDialogActionReceived(npcID: packet.NpcID, action: .next)
            self.postEvent(event)
        }

        // See `clif_scriptclose`
        subscription.subscribe(to: PACKET_ZC_CLOSE_DIALOG.self) { [unowned self] packet in
            let event = MapSession.Event.npcDialogActionReceived(npcID: packet.npcId, action: .close)
            self.postEvent(event)
        }

        // See `clif_scriptclear`
        subscription.subscribe(to: PACKET_ZC_CLEAR_DIALOG.self) { [unowned self] packet in
            let event = MapSession.Event.npcDialogClosed(npcID: packet.GID)
            self.postEvent(event)
        }

        // See `clif_scriptmenu`
        subscription.subscribe(to: PACKET_ZC_MENU_LIST.self) { [unowned self] packet in
            let menu = packet.menu.split(separator: ":").map(String.init)
            let event = MapSession.Event.npcDialogMenuReceived(npcID: packet.npcId, menu: menu)
            self.postEvent(event)
        }

        // See `clif_scriptinput`
        subscription.subscribe(to: PACKET_ZC_OPEN_EDITDLG.self) { [unowned self] packet in
            let event = MapSession.Event.npcDialogInputReceived(npcID: packet.npcId, input: .number)
            self.postEvent(event)
        }

        // See `clif_scriptinputstr`
        subscription.subscribe(to: PACKET_ZC_OPEN_EDITDLGSTR.self) { [unowned self] packet in
            let event = MapSession.Event.npcDialogInputReceived(npcID: packet.npcId, input: .text)
            self.postEvent(event)
        }

        // See `clif_cutin`
        subscription.subscribe(to: PACKET_ZC_SHOW_IMAGE.self) { [unowned self] packet in
            let event = MapSession.Event.npcImageReceived(image: packet.image)
            self.postEvent(event)
        }

        // See `clif_viewpoint`
        subscription.subscribe(to: PACKET_ZC_COMPASS.self) { [unowned self] packet in
            let event = MapSession.Event.minimapMarkPositionReceived(
                npcID: packet.npcId,
                position: SIMD2(x: Int(packet.xPos), y: Int(packet.yPos))
            )
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
        var packet = PACKET_CZ_REQ_NEXT_SCRIPT()
        packet.packetType = HEADER_CZ_REQ_NEXT_SCRIPT
        packet.npcID = npcID

        client.sendPacket(packet)
    }

    // See `clif_parse_NpcCloseClicked`
    public func closeDialog(npcID: UInt32) {
        var packet = PACKET_CZ_CLOSE_DIALOG()
        packet.packetType = HEADER_CZ_CLOSE_DIALOG
        packet.GID = npcID

        client.sendPacket(packet)
    }

    // See `clif_parse_NpcSelectMenu`
    public func selectMenu(npcID: UInt32, select: UInt8) {
        var packet = PACKET_CZ_CHOOSE_MENU()
        packet.packetType = HEADER_CZ_CHOOSE_MENU
        packet.npcID = npcID
        packet.select = select

        client.sendPacket(packet)
    }

    // See `clif_parse_NpcAmountInput`
    public func inputNumber(npcID: UInt32, value: Int32) {
        var packet = PACKET_CZ_INPUT_EDITDLG()
        packet.packetType = HEADER_CZ_INPUT_EDITDLG
        packet.GID = npcID
        packet.value = value

        client.sendPacket(packet)
    }

    // See `clif_parse_NpcStringInput`
    public func inputText(npcID: UInt32, value: String) {
        var packet = PACKET_CZ_INPUT_EDITDLGSTR()
        packet.packetType = HEADER_CZ_INPUT_EDITDLGSTR
        packet.packetLength = Int16(2 + 2 + 4 + value.utf8.count)
        packet.GID = Int32(npcID)
        packet.value = value

        client.sendPacket(packet)
    }
}
