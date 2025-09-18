//
//  NPCDialog.swift
//  NetworkClient
//
//  Created by Leon Li on 2024/12/16.
//

public struct NPCDialog: Sendable {
    public enum Content: Sendable {
        case message(message: String, hasNextMessage: Bool?)
        case menu(menu: [String])
        case numberInput
        case textInput
    }

    public let objectID: UInt32
    public let content: NPCDialog.Content

    public init(objectID: UInt32, content: NPCDialog.Content) {
        self.objectID = objectID
        self.content = content
    }
}
