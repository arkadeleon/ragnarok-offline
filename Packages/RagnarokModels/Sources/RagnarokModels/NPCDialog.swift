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
