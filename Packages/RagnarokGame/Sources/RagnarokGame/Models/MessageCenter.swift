//
//  MessageCenter.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/23.
//

import Foundation
import Observation
import RagnarokLocalization
import RagnarokModels
import RagnarokPackets

@Observable
final class MessageCenter {
    enum MessageType {
        case system
        case info
        case error
    }

    enum MessageCategory {
        case item
        case battle
    }

    struct Message: Identifiable {
        let id = UUID()
        var content: String
        var type: MessageCenter.MessageType?
        var category: MessageCenter.MessageCategory?

        init(content: String, type: MessageCenter.MessageType, category: MessageCenter.MessageCategory) {
            self.content = content
            self.type = type
            self.category = category
        }

        init(from message: ChatMessage) {
            self.content = message.content
        }
    }

    let itemInfoTable: ItemInfoTable
    let messageStringTable: MessageStringTable

    var messages: [MessageCenter.Message] = []

    init(itemInfoTable: ItemInfoTable, messageStringTable: MessageStringTable) {
        self.itemInfoTable = itemInfoTable
        self.messageStringTable = messageStringTable
    }

    func add(_ message: ChatMessage) {
        messages.append(.init(from: message))
    }

    // MARK: - Item

    func addMessage(for packet: PACKET_ZC_ITEM_PICKUP_ACK) {
        if packet.result == 0 {
            let itemName = itemInfoTable.localizedIdentifiedItemName(forItemID: Int(packet.nameid)) ?? "\(packet.nameid)"
            let messageString = messageStringTable.localizedMessageString(forID: 153, arguments: itemName, packet.count)
            let message = MessageCenter.Message(content: messageString, type: .system, category: .item)
            messages.append(message)
        } else {
            let messageString = messageStringTable.localizedMessageString(forID: 53)
            let message = MessageCenter.Message(content: messageString, type: .error, category: .item)
            messages.append(message)
        }
    }

    func addMessage(for packet: PACKET_ZC_REQ_WEAR_EQUIP_ACK, itemID: Int) {
        if packet.result == 1 {
            let itemName = itemInfoTable.localizedIdentifiedItemName(forItemID: itemID) ?? "\(itemID)"
            let messageString = messageStringTable.localizedMessageString(forID: 170)
            let message = MessageCenter.Message(content: "\(itemName) " + messageString, type: .system, category: .item)
            messages.append(message)
        } else {
            let messageString = messageStringTable.localizedMessageString(forID: 372)
            let message = MessageCenter.Message(content: messageString, type: .error, category: .item)
            messages.append(message)
        }
    }

    func addMessage(for packet: PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK, itemID: Int) {
        if packet.flag != 0 {
            let itemName = itemInfoTable.localizedIdentifiedItemName(forItemID: itemID) ?? "\(itemID)"
            let messageString = messageStringTable.localizedMessageString(forID: 171)
            let message = MessageCenter.Message(content: "\(itemName) " + messageString, type: .error, category: .item)
            messages.append(message)
        }
    }

    func addMessage(for packet: PACKET_ZC_ACK_ADDITEM_TO_CART) {
        if packet.result == 0 {
            let messageString = messageStringTable.localizedMessageString(forID: 220)
            let message = MessageCenter.Message(content: messageString, type: .error, category: .item)
            messages.append(message)
        } else if packet.result == 1 {
            let messageString = messageStringTable.localizedMessageString(forID: 221)
            let message = MessageCenter.Message(content: messageString, type: .error, category: .item)
            messages.append(message)
        }
    }

    // MARK: - Battle

    func addMessage(for objectAction: MapObjectAction, account: AccountInfo?) {
        if objectAction.damage > 0 {
            if objectAction.sourceObjectID == account?.accountID {
                // I deal damage
                let messageString = messageStringTable.localizedMessageString(forID: 1607, arguments: "\(objectAction.targetObjectID)", objectAction.damage)
                let message = MessageCenter.Message(content: messageString, type: .info, category: .battle)
                messages.append(message)
            } else if objectAction.targetObjectID == account?.accountID {
                // I receive damage
                let messageString = messageStringTable.localizedMessageString(forID: 1605, arguments: "\(objectAction.sourceObjectID)", objectAction.damage)
                let message = MessageCenter.Message(content: messageString, type: .info, category: .battle)
                messages.append(message)
            }

            // TODO: My buddy deals damage

            // TODO: My buddy receives damage

            // TODO: Party member deals damage

            // TODO: Party member receives damage
        }
    }
}
