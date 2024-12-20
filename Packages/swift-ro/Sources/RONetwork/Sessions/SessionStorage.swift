//
//  SessionStorage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import ROGenerated

final public actor SessionStorage {
    public let langType: UInt16 = 1

    public private(set) var accountID: UInt32 = 0
    public private(set) var loginID1: UInt32 = 0
    public private(set) var loginID2: UInt32 = 0
    public private(set) var sex: UInt8 = 0

    public private(set) var charServers: [CharServerInfo] = []

    public private(set) var chars: [CharInfo] = []
    public private(set) var charID: UInt32 = 0

    public private(set) var mapName: String?
    public private(set) var mapServer: MapServerInfo?

    public private(set) var player: Player?

    public private(set) var mapObjects: [UInt32 : MapObject] = [:]

    public private(set) var npcDialog: NPCDialog?

    public init() {
    }

    func updateAccount(with packet: PACKET_AC_ACCEPT_LOGIN) {
        accountID = packet.AID
        loginID1 = packet.login_id1
        loginID2 = packet.login_id2
        sex = packet.sex
        charServers = packet.char_servers.map(CharServerInfo.init)
    }

    func updateAccountID(_ accountID: UInt32) {
        self.accountID = accountID
    }

    func updateChars(_ chars: [CharInfo]) {
        self.chars = chars
    }

    func addChar(_ char: CharInfo) {
        chars.append(char)
    }

    func updateCharID(_ charID: UInt32) {
        self.charID = charID
    }

    func updateMapServer(with packet: PACKET_HC_NOTIFY_ZONESVR) {
        self.charID = packet.charID
        self.mapName = packet.mapName
        self.mapServer = packet.mapServer

        player = Player()
    }

    func updateMap(with mapName: String, position: SIMD2<Int16>) {
        self.mapName = mapName
        player?.position = position
        mapObjects.removeAll()
        npcDialog = nil
    }

    // MARK: - Player

    func updatePlayerPosition(_ position: SIMD2<Int16>) {
        player?.position = position
    }

    func updatePlayerStatus(with packet: PACKET_ZC_STATUS) {
        player?.status.update(with: packet)
    }

    func updatePlayerStatusProperty(_ sp: StatusProperty, value: Int) {
        player?.status.update(property: sp, value: value)
    }

    func updatePlayerStatusProperty(_ sp: StatusProperty, value: Int, value2: Int) {
        player?.status.update(property: sp, value: value, value2: value2)
    }

    // MARK: - Map Objects

    @discardableResult
    func updateMapObject(_ object: MapObject) -> MapObject? {
        mapObjects.updateValue(object, forKey: object.id)
    }

    @discardableResult
    func removeMapObject(for objectID: UInt32) -> MapObject? {
        mapObjects.removeValue(forKey: objectID)
    }

    func updateMapObjectPosition(_ objectID: UInt32, position: SIMD2<Int16>) -> MapObject? {
        guard var object = mapObjects[objectID] else {
            return nil
        }

        object.position = position
        mapObjects[objectID] = object

        return object
    }

    func updateMapObjectState(with packet: PACKET_ZC_STATE_CHANGE) -> MapObject? {
        guard var object = mapObjects[packet.AID] else {
            return nil
        }

        object.updateState(with: packet)
        mapObjects[packet.AID] = object

        return object
    }

    // MARK: - NPC Dialog

    func updateNPCDialog(with packet: PACKET_ZC_SAY_DIALOG) {
        if let npcDialog, npcDialog.npcID == packet.NpcID, case .message(var message, let hasNextMessage) = npcDialog.content {
            message.append("\n")
            message.append(packet.message)
            let npcDialog = NPCDialog(npcID: packet.NpcID, content: .message(message: message, hasNextMessage: hasNextMessage))
            self.npcDialog = npcDialog
        } else {
            let npcDialog = NPCDialog(npcID: packet.NpcID, content: .message(message: packet.message, hasNextMessage: nil))
            self.npcDialog = npcDialog
        }
    }

    func updateNPCDialog(with packet: PACKET_ZC_WAIT_DIALOG) -> NPCDialog? {
        if let npcDialog, npcDialog.npcID == packet.NpcID, case .message(let message, _) = npcDialog.content {
            let npcDialog = NPCDialog(npcID: npcDialog.npcID, content: .message(message: message, hasNextMessage: true))
            self.npcDialog = npcDialog
            return npcDialog
        } else {
            return nil
        }
    }

    func updateNPCDialog(with packet: PACKET_ZC_CLOSE_DIALOG) -> NPCDialog? {
        if let npcDialog, npcDialog.npcID == packet.npcId, case .message(let message, _) = npcDialog.content {
            let npcDialog = NPCDialog(npcID: npcDialog.npcID, content: .message(message: message, hasNextMessage: false))
            self.npcDialog = npcDialog
            return npcDialog
        } else {
            return nil
        }
    }

    func updateNPCDialog(with packet: PACKET_ZC_MENU_LIST) -> NPCDialog {
        let menu = packet.menu.split(separator: ":").map(String.init)
        let npcDialog = NPCDialog(npcID: packet.npcId, content: .menu(menu: menu))
        self.npcDialog = npcDialog
        return npcDialog
    }

    func updateNPCDialog(with packet: PACKET_ZC_OPEN_EDITDLG) -> NPCDialog {
        let npcDialog = NPCDialog(npcID: packet.npcId, content: .textInput)
        self.npcDialog = npcDialog
        return npcDialog
    }

    func updateNPCDialog(with packet: PACKET_ZC_OPEN_EDITDLGSTR) -> NPCDialog {
        let npcDialog = NPCDialog(npcID: packet.npcId, content: .textInput)
        self.npcDialog = npcDialog
        return npcDialog
    }

    func closeNPCDialog() {
        npcDialog = nil
    }
}
