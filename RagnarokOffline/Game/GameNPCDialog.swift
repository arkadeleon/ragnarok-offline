//
//  GameNPCDialog.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/8.
//

import Observation

@Observable
final class GameNPCDialog {
    let npcID: UInt32
    var message: String
    var showsNextButton = false
    var showsCloseButton = false

    init(npcID: UInt32, message: String) {
        self.npcID = npcID
        self.message = message
    }
}

@Observable
final class GameNPCMenuDialog {
    let npcID: UInt32
    let items: [String]

    init(npcID: UInt32, items: [String]) {
        self.npcID = npcID
        self.items = items
    }
}
