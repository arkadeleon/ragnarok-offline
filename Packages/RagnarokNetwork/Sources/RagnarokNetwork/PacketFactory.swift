//
//  PacketFactory.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2026/1/9.
//

import Foundation
import RagnarokConstants
import RagnarokModels
import RagnarokPackets

public enum PacketFactory {

    // MARK: - CA (Client → Login Server)

    /// | `PACKET_CA_LOGIN` | `logclif_parse_reqauth_raw` |
    public static func CA_LOGIN(username: String, password: String) -> PACKET_CA_LOGIN {
        var packet = PACKET_CA_LOGIN()
        packet.packetType = HEADER_CA_LOGIN
        packet.version = 0
        packet.username = username
        packet.password = password
        packet.clienttype = 0
        return packet
    }

    /// | `PACKET_CA_CONNECT_INFO_CHANGED` | `logclif_parse_keepalive` |
    public static func CA_CONNECT_INFO_CHANGED(username: String) -> PACKET_CA_CONNECT_INFO_CHANGED {
        var packet = PACKET_CA_CONNECT_INFO_CHANGED()
        packet.packetType = HEADER_CA_CONNECT_INFO_CHANGED
        packet.name = username
        return packet
    }

    // MARK: - CH (Client → Char Server)

    /// | `PACKET_CH_ENTER` | `chclif_parse_reqtoconnect` |
    public static func CH_ENTER(account: AccountInfo) -> PACKET_CH_ENTER {
        var packet = PACKET_CH_ENTER()
        packet.packetType = HEADER_CH_ENTER
        packet.accountID = account.accountID
        packet.loginID1 = account.loginID1
        packet.loginID2 = account.loginID2
        packet.clientType = account.langType
        packet.sex = UInt8(account.sex)
        return packet
    }

    /// | `PACKET_CH_SELECT_CHAR` | `chclif_parse_charselect` |
    public static func CH_SELECT_CHAR(slot: Int) -> PACKET_CH_SELECT_CHAR {
        var packet = PACKET_CH_SELECT_CHAR()
        packet.packetType = HEADER_CH_SELECT_CHAR
        packet.slot = UInt8(slot)
        return packet
    }

    /// | `PACKET_CH_MAKE_CHAR` | `chclif_parse_createnewchar` |
    public static func CH_MAKE_CHAR(character: CharacterInfo) -> PACKET_CH_MAKE_CHAR {
        var packet = PACKET_CH_MAKE_CHAR()
        packet.packetType = HEADER_CH_MAKE_CHAR
        packet.name = character.name
        packet.slot = UInt8(character.charNum)
        packet.hair_color = UInt16(character.headPalette)
        packet.hair_style = UInt16(character.head)
        packet.job = UInt32(character.job)
        packet.sex = UInt8(character.sex)
        return packet
    }

    /// | `PACKET_CH_DELETE_CHAR3` | `chclif_parse_char_delete2_accept` |
    public static func CH_DELETE_CHAR3(charID: UInt32) -> PACKET_CH_DELETE_CHAR3 {
        var packet = PACKET_CH_DELETE_CHAR3()
        packet.packetType = HEADER_CH_DELETE_CHAR3
        packet.CID = charID
        return packet
    }

    /// | `PACKET_PING` | `chclif_parse_keepalive` |
    public static func PING(accountID: UInt32) -> PACKET_PING {
        var packet = PACKET_PING()
        packet.packetType = HEADER_PING
        packet.AID = accountID
        return packet
    }

    // MARK: - CZ (Client → Map Server)

    /// | `PACKET_CZ_ENTER` | `clif_parse_LoadEndAck` |
    public static func CZ_ENTER(account: AccountInfo, charID: UInt32) -> PACKET_CZ_ENTER {
        var packet = PACKET_CZ_ENTER()
        packet.accountID = account.accountID
        packet.charID = charID
        packet.loginID1 = account.loginID1
        packet.clientTime = UInt32(Date.now.timeIntervalSince1970)
        packet.sex = UInt8(account.sex)
        return packet
    }

    /// | `PACKET_CZ_REQUEST_MOVE` | `clif_parse_WalkToXY` |
    public static func CZ_REQUEST_MOVE(position: SIMD2<Int>) -> PACKET_CZ_REQUEST_MOVE {
        var packet = PACKET_CZ_REQUEST_MOVE()
        packet.x = Int16(position.x)
        packet.y = Int16(position.y)
        return packet
    }

    /// | `PACKET_CZ_NOTIFY_ACTORINIT` | `clif_parse_LoadEndAck` |
    public static func CZ_NOTIFY_ACTORINIT() -> PACKET_CZ_NOTIFY_ACTORINIT {
        var packet = PACKET_CZ_NOTIFY_ACTORINIT()
        packet.packetType = HEADER_CZ_NOTIFY_ACTORINIT
        return packet
    }

    /// | `PACKET_CZ_RESTART` | `clif_parse_Restart` |
    public static func CZ_RESTART(type: UInt8) -> PACKET_CZ_RESTART {
        var packet = PACKET_CZ_RESTART()
        packet.type = type
        return packet
    }

    /// | `PACKET_CZ_REQUEST_QUIT` | `clif_parse_QuitGame` |
    public static func CZ_REQUEST_QUIT() -> PACKET_CZ_REQUEST_QUIT {
        var packet = PACKET_CZ_REQUEST_QUIT()
        packet.packetType = HEADER_CZ_REQUEST_QUIT
        return packet
    }

    /// | `PACKET_CZ_REQUEST_TIME` | `clif_keepalive` |
    public static func CZ_REQUEST_TIME(clientTime: UInt32) -> PACKET_CZ_REQUEST_TIME {
        var packet = PACKET_CZ_REQUEST_TIME()
        packet.clientTime = clientTime
        return packet
    }

    /// | `PACKET_CZ_REQUEST_ACT` | `clif_parse_ActionRequest` |
    public static func CZ_REQUEST_ACT(targetID: UInt32, actionType: DamageType) -> PACKET_CZ_REQUEST_ACT {
        var packet = PACKET_CZ_REQUEST_ACT()
        packet.targetID = targetID
        packet.action = UInt8(actionType.rawValue)
        return packet
    }

    /// | `PACKET_CZ_CHANGE_DIRECTION` | `clif_parse_ChangeDir` |
    public static func CZ_CHANGE_DIRECTION(headDirection: UInt16, direction: UInt8) -> PACKET_CZ_CHANGE_DIRECTION {
        var packet = PACKET_CZ_CHANGE_DIRECTION()
        packet.headDirection = headDirection
        packet.direction = direction
        return packet
    }

    /// | `PACKET_CZ_STATUS_CHANGE` | `clif_parse_StatusUp` |
    public static func CZ_STATUS_CHANGE(property: StatusProperty, amount: Int) -> PACKET_CZ_STATUS_CHANGE {
        var packet = PACKET_CZ_STATUS_CHANGE()
        packet.statusID = Int16(property.rawValue)
        packet.amount = Int8(amount)
        return packet
    }

    /// | `PACKET_CZ_ADVANCED_STATUS_CHANGE` | `clif_parse_traitstatus_up` |
    public static func CZ_ADVANCED_STATUS_CHANGE(property: StatusProperty, amount: Int) -> PACKET_CZ_ADVANCED_STATUS_CHANGE {
        var packet = PACKET_CZ_ADVANCED_STATUS_CHANGE()
        packet.packetType = HEADER_CZ_ADVANCED_STATUS_CHANGE
        packet.type = Int16(property.rawValue)
        packet.amount = Int16(amount)
        return packet
    }

    /// | `PACKET_CZ_REQUEST_CHAT` | `clif_parse_GlobalMessage` |
    public static func CZ_REQUEST_CHAT(message: String) -> PACKET_CZ_REQUEST_CHAT {
        var packet = PACKET_CZ_REQUEST_CHAT()
        packet.message = message
        return packet
    }

    /// | `PACKET_CZ_ITEM_PICKUP` | `clif_parse_TakeItem` |
    public static func CZ_ITEM_PICKUP(objectID: UInt32) -> PACKET_CZ_ITEM_PICKUP {
        var packet = PACKET_CZ_ITEM_PICKUP()
        packet.objectID = objectID
        return packet
    }

    /// | `PACKET_CZ_ITEM_THROW` | `clif_parse_DropItem` |
    public static func CZ_ITEM_THROW(index: Int, amount: Int) -> PACKET_CZ_ITEM_THROW {
        var packet = PACKET_CZ_ITEM_THROW()
        packet.index = UInt16(index)
        packet.amount = Int16(amount)
        return packet
    }

    /// | `PACKET_CZ_USE_ITEM` | `clif_parse_UseItem` |
    public static func CZ_USE_ITEM(index: Int, accountID: UInt32) -> PACKET_CZ_USE_ITEM {
        var packet = PACKET_CZ_USE_ITEM()
        packet.index = UInt16(index)
        packet.accountID = accountID
        return packet
    }

    /// | `PACKET_CZ_REQ_WEAR_EQUIP` | `clif_parse_EquipItem` |
    public static func CZ_REQ_WEAR_EQUIP(index: Int, location: EquipPositions) -> PACKET_CZ_REQ_WEAR_EQUIP {
        var packet = PACKET_CZ_REQ_WEAR_EQUIP()
        packet.packetType = HEADER_CZ_REQ_WEAR_EQUIP
        packet.index = UInt16(index)
        packet.position = UInt32(location.rawValue)
        return packet
    }

    /// | `PACKET_CZ_REQ_TAKEOFF_EQUIP` | `clif_parse_UnequipItem` |
    public static func CZ_REQ_TAKEOFF_EQUIP(index: Int) -> PACKET_CZ_REQ_TAKEOFF_EQUIP {
        var packet = PACKET_CZ_REQ_TAKEOFF_EQUIP()
        packet.index = UInt16(index)
        return packet
    }

    /// | `PACKET_CZ_CONTACTNPC` | `clif_parse_NpcClicked` |
    public static func CZ_CONTACTNPC(npcID: UInt32) -> PACKET_CZ_CONTACTNPC {
        var packet = PACKET_CZ_CONTACTNPC()
        packet.packetType = HEADER_CZ_CONTACTNPC
        packet.AID = npcID
        packet.type = 1
        return packet
    }

    /// | `PACKET_CZ_REQ_NEXT_SCRIPT` | `clif_parse_NpcNextClicked` |
    public static func CZ_REQ_NEXT_SCRIPT(npcID: UInt32) -> PACKET_CZ_REQ_NEXT_SCRIPT {
        var packet = PACKET_CZ_REQ_NEXT_SCRIPT()
        packet.packetType = HEADER_CZ_REQ_NEXT_SCRIPT
        packet.npcID = npcID
        return packet
    }

    /// | `PACKET_CZ_CLOSE_DIALOG` | `clif_parse_NpcCloseClicked` |
    public static func CZ_CLOSE_DIALOG(npcID: UInt32) -> PACKET_CZ_CLOSE_DIALOG {
        var packet = PACKET_CZ_CLOSE_DIALOG()
        packet.packetType = HEADER_CZ_CLOSE_DIALOG
        packet.GID = npcID
        return packet
    }

    /// | `PACKET_CZ_CHOOSE_MENU` | `clif_parse_NpcSelectMenu` |
    public static func CZ_CHOOSE_MENU(npcID: UInt32, select: UInt8) -> PACKET_CZ_CHOOSE_MENU {
        var packet = PACKET_CZ_CHOOSE_MENU()
        packet.packetType = HEADER_CZ_CHOOSE_MENU
        packet.npcID = npcID
        packet.select = select
        return packet
    }

    /// | `PACKET_CZ_INPUT_EDITDLG` | `clif_parse_NpcAmountInput` |
    public static func CZ_INPUT_EDITDLG(npcID: UInt32, value: Int32) -> PACKET_CZ_INPUT_EDITDLG {
        var packet = PACKET_CZ_INPUT_EDITDLG()
        packet.packetType = HEADER_CZ_INPUT_EDITDLG
        packet.GID = npcID
        packet.value = value
        return packet
    }

    /// | `PACKET_CZ_INPUT_EDITDLGSTR` | `clif_parse_NpcStringInput` |
    public static func CZ_INPUT_EDITDLGSTR(npcID: UInt32, value: String) -> PACKET_CZ_INPUT_EDITDLGSTR {
        var packet = PACKET_CZ_INPUT_EDITDLGSTR()
        packet.packetType = HEADER_CZ_INPUT_EDITDLGSTR
        packet.packetLength = Int16(2 + 2 + 4 + value.utf8.count)
        packet.GID = Int32(npcID)
        packet.value = value
        return packet
    }

    /// | `PACKET_CZ_PING_LIVE` | `clif_parse_dull` |
    public static func CZ_PING_LIVE() -> PACKET_CZ_PING_LIVE {
        var packet = PACKET_CZ_PING_LIVE()
        packet.packetType = HEADER_CZ_PING_LIVE
        return packet
    }
}
