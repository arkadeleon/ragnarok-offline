//
//  NPCDialog.swift
//  RagnarokModels
//
//  Created by Leon Li on 2024/12/16.
//

import RagnarokPackets

public enum NPCDialogAction: Sendable {
    case next
    case close
}

public enum NPCDialogInput: Sendable {
    case number
    case text
}

public struct NPCDialog {
    public let npcID: UInt32

    public private(set) var message: String
    public private(set) var action: NPCDialogAction?
    public private(set) var menu: [String]?
    public private(set) var input: NPCDialogInput?

    private var needsClearMessage = false

    public init(npcID: UInt32, message: String, action: NPCDialogAction? = nil, menu: [String]? = nil, input: NPCDialogInput? = nil) {
        self.npcID = npcID
        self.message = message
        self.action = action
        self.menu = menu
        self.input = input
    }

    public init(from packet: PACKET_ZC_SAY_DIALOG) {
        self.npcID = packet.NpcID
        self.message = packet.message
    }

    // MARK: - Update

    public mutating func update(from packet: PACKET_ZC_SAY_DIALOG) {
        guard packet.NpcID == npcID else {
            return
        }

        clearMessageIfNeeded()
        append(message: packet.message)
    }

    public mutating func update(from packet: PACKET_ZC_WAIT_DIALOG) {
        guard packet.NpcID == npcID else {
            return
        }

        action = .next
    }

    public mutating func update(from packet: PACKET_ZC_CLOSE_DIALOG) {
        guard packet.npcId == npcID else {
            return
        }

        action = .close
        menu = nil
        input = nil
    }

    public mutating func update(from packet: PACKET_ZC_MENU_LIST) {
        guard packet.npcId == npcID else {
            return
        }

        action = nil
        menu = packet.menu.split(separator: ":").map(String.init)
    }

    public mutating func update(from packet: PACKET_ZC_OPEN_EDITDLG) {
        guard packet.npcId == npcID else {
            return
        }

        action = nil
        input = .number
    }

    public mutating func update(from packet: PACKET_ZC_OPEN_EDITDLGSTR) {
        guard packet.npcId == npcID else {
            return
        }

        action = nil
        input = .text
    }

    // MARK: - Clear

    public mutating func setNeedsClearMessage() {
        needsClearMessage = true
    }

    public mutating func clearAction() {
        action = nil
    }

    public mutating func clearMenu() {
        menu = nil
    }

    public mutating func clearInput() {
        input = nil
    }

    // MARK: - Private

    private mutating func clearMessageIfNeeded() {
        if needsClearMessage {
            message = ""
            needsClearMessage = false
        }
    }

    private mutating func append(message: String) {
        if !self.message.isEmpty {
            self.message.append("\n")
        }
        self.message.append(message)
    }
}
