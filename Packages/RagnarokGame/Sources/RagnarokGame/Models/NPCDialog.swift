//
//  NPCDialog.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/12/1.
//

import Observation
import RagnarokNetwork

@Observable
final class NPCDialog {
    let npcID: UInt32
    var message: String
    var action: NPCDialogAction?
    var menu: [String]?
    var input: NPCDialogInput?

    @ObservationIgnored
    private var needsClear = false

    init(npcID: UInt32, message: String) {
        self.npcID = npcID
        self.message = message
    }

    func append(message: String) {
        if !self.message.isEmpty {
            self.message.append("\n")
        }
        self.message.append(message)
    }

    func setNeedsClear() {
        needsClear = true
    }

    func clearIfNeeded() {
        if needsClear {
            message = ""
            needsClear = false
        }
    }
}
