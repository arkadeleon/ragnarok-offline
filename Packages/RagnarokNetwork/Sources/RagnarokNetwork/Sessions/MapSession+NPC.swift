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
        let packet = PacketFactory.CZ_CONTACTNPC(npcID: npcID)
        client.sendPacket(packet)
    }

    // See `clif_parse_NpcNextClicked`
    public func requestNextMessage(npcID: UInt32) {
        let packet = PacketFactory.CZ_REQ_NEXT_SCRIPT(npcID: npcID)
        client.sendPacket(packet)
    }

    // See `clif_parse_NpcCloseClicked`
    public func closeDialog(npcID: UInt32) {
        let packet = PacketFactory.CZ_CLOSE_DIALOG(npcID: npcID)
        client.sendPacket(packet)
    }

    // See `clif_parse_NpcSelectMenu`
    public func selectMenu(npcID: UInt32, select: UInt8) {
        let packet = PacketFactory.CZ_CHOOSE_MENU(npcID: npcID, select: select)
        client.sendPacket(packet)
    }

    // See `clif_parse_NpcAmountInput`
    public func inputNumber(npcID: UInt32, value: Int32) {
        let packet = PacketFactory.CZ_INPUT_EDITDLG(npcID: npcID, value: value)
        client.sendPacket(packet)
    }

    // See `clif_parse_NpcStringInput`
    public func inputText(npcID: UInt32, value: String) {
        let packet = PacketFactory.CZ_INPUT_EDITDLGSTR(npcID: npcID, value: value)
        client.sendPacket(packet)
    }
}
