//
//  NPCDialog.swift
//  RagnarokModels
//
//  Created by Leon Li on 2024/12/16.
//

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
    public var message: String
    public var action: NPCDialogAction?
    public var menu: [String]?
    public var input: NPCDialogInput?

    private var needsClear = false

    public init(npcID: UInt32, message: String) {
        self.npcID = npcID
        self.message = message
    }

    public mutating func append(message: String) {
        if !self.message.isEmpty {
            self.message.append("\n")
        }
        self.message.append(message)
    }

    public mutating func setNeedsClear() {
        needsClear = true
    }

    public mutating func clearIfNeeded() {
        if needsClear {
            message = ""
            needsClear = false
        }
    }
}
