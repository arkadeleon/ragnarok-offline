//
//  NPCEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/6.
//

import ROGenerated

public enum NPCEvents {
    public struct DisplayDialog: Event {
        public let npcID: UInt32
        public let message: String

        init(packet: PACKET_ZC_SAY_DIALOG) {
            self.npcID = packet.NpcID
            self.message = packet.message
        }
    }

    public struct AddNextButton: Event {
        public let npcID: UInt32

        init(packet: PACKET_ZC_WAIT_DIALOG) {
            self.npcID = packet.NpcID
        }
    }

    public struct AddCloseButton: Event {
        public let npcID: UInt32

        init(packet: PACKET_ZC_CLOSE_DIALOG) {
            self.npcID = packet.npcId
        }
    }

    public struct CloseDialog: Event {
        public let npcID: UInt32

        init(packet: PACKET_ZC_CLEAR_DIALOG) {
            self.npcID = packet.GID
        }
    }

    public struct DisplayMenuDialog: Event {
        public let npcID: UInt32
        public let items: [String]

        init(packet: PACKET_ZC_MENU_LIST) {
            self.npcID = packet.npcId
            self.items = packet.menu.split(separator: ":").map(String.init)
        }
    }

    public struct DisplayNumberInputDialog: Event {
        public let npcID: UInt32

        init(packet: PACKET_ZC_OPEN_EDITDLG) {
            self.npcID = packet.npcId
        }
    }

    public struct DisplayTextInputDialog: Event {
        public let npcID: UInt32

        init(packet: PACKET_ZC_OPEN_EDITDLGSTR) {
            self.npcID = packet.npcId
        }
    }

    public struct DisplayImage: Event {
        public let image: String

        init(packet: PACKET_ZC_SHOW_IMAGE) {
            self.image = packet.image
        }
    }

    public struct MarkPosition: Event {
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
