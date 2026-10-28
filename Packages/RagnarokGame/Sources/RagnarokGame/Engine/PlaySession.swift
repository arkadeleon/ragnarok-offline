//
//  PlaySession.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/28.
//

import Foundation
import Observation
import RagnarokConstants
import RagnarokModels
import RagnarokNetwork
import RagnarokPackets

@MainActor
@Observable
final class PlaySession {
    var account: AccountInfo
    let character: CharacterInfo

    var playerStatus: CharacterStatus
    var inventory: Inventory
    var skillList: SkillList
    var skillCooldowns: [Int : SkillCooldown]
    var statusChanges: [StatusChange]
    var shortcutList: ShortcutList
    let messageCenter: MessageCenter

    var dialog: NPCDialog?
    var dealSelectionNPCID: UInt32?
    var npcShop: NPCShop?
    var storage: Storage?
    var warpList: WarpList?

    var interactionMode: GameInteractionMode = .direct

    @ObservationIgnored private(set) var mapClient: NetworkClient?
    @ObservationIgnored private var keepaliveTask: Task<Void, Never>?

    @ObservationIgnored var serverClock = ServerClock()
    @ObservationIgnored var serverTimeRequestTime: ContinuousClock.Instant?

    init(context: GameContext, account: AccountInfo, character: CharacterInfo, mapClient: NetworkClient? = nil) {
        self.account = account
        self.character = character
        self.mapClient = mapClient

        self.playerStatus = CharacterStatus(from: character)
        self.inventory = Inventory()
        self.skillList = SkillList()
        self.skillCooldowns = [:]
        self.statusChanges = []
        self.shortcutList = ShortcutList()
        self.messageCenter = MessageCenter(
            itemInfoTable: context.itemInfoTable,
            messageStringTable: context.messageStringTable
        )
    }

    /// Keeps the current cooldown when it would end later than the new one.
    func setSkillCooldown(_ cooldown: SkillCooldown) {
        if let current = skillCooldowns[cooldown.skillID], current.endTime >= cooldown.endTime {
            return
        }
        skillCooldowns[cooldown.skillID] = cooldown
    }

    /// Puts every skill in the shortcut list on cooldown, such as after a skill with a cast delay.
    func setGlobalSkillCooldown(startTime: ContinuousClock.Instant, duration: Duration) {
        for shortcut in shortcutList.rows.joined() {
            if case .skill(let skillID, _) = shortcut {
                let cooldown = SkillCooldown(skillID: skillID, startTime: startTime, duration: duration)
                setSkillCooldown(cooldown)
            }
        }
    }

    /// A status which is already active keeps its place in the list.
    func setStatusChange(_ statusChange: StatusChange) {
        if let index = statusChanges.firstIndex(where: { $0.statusID == statusChange.statusID }) {
            statusChanges[index] = statusChange
        } else {
            statusChanges.append(statusChange)
        }
    }

    func removeStatusChange(statusID: Int) {
        statusChanges.removeAll(where: { $0.statusID == statusID })
    }

    // MARK: - Map Client

    func start() {
        guard let mapClient else {
            return
        }

        mapClient.connect()

        let packet = PacketFactory.CZ_ENTER(account: account, charID: character.charID)
        mapClient.sendPacket(packet)

        if PACKET_VERSION < 20070521 {
            mapClient.receiveDataAndPacket(count: 4) { [weak self] data in
                let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
                Task { @MainActor in
                    self?.account.update(accountID: accountID)
                }
            }
        } else {
            mapClient.receivePacket()
        }

        startKeepalive()
    }

    func stop() {
        keepaliveTask?.cancel()
        keepaliveTask = nil

        mapClient?.disconnect()
        mapClient = nil
    }

    /// Keep alive and synchronize the server clock.
    ///
    /// Send ``PACKET_CZ_REQUEST_TIME`` every second for the first 5 seconds, then every 10 seconds.
    /// The map server drops it until the map is loaded, so it restarts after each map load.
    private func startKeepalive() {
        guard let mapClient else {
            return
        }

        let startTime = ContinuousClock.now

        keepaliveTask?.cancel()
        keepaliveTask = Task {
            var requestCount = 0
            while !Task.isCancelled {
                let now = ContinuousClock.now
                let clientTime = Int(startTime.duration(to: now).timeInterval * 1000)
                serverTimeRequestTime = now

                let packet = PacketFactory.CZ_REQUEST_TIME(clientTime: UInt32(truncatingIfNeeded: clientTime))
                mapClient.sendPacket(packet)

                try? await Task.sleep(for: requestCount < 5 ? .seconds(1) : .seconds(10))
                requestCount += 1
            }
        }
    }

    // MARK: - Map Operations

    func notifyMapLoaded() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_NOTIFY_ACTORINIT()
        mapClient.sendPacket(packet)

        startKeepalive()
    }

    func resurrectInPlace() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_STANDING_RESURRECTION()
        mapClient.sendPacket(packet)
    }

    func returnToLastSavePoint() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_RESTART(type: 0)
        mapClient.sendPacket(packet)
    }

    func returnToCharacterSelect() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_RESTART(type: 1)
        mapClient.sendPacket(packet)
    }

    func requestExit() {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQUEST_QUIT()
        mapClient.sendPacket(packet)
    }

    // MARK: - Player

    /// Request move to position.
    ///
    /// Send ``PACKET_CZ_REQUEST_MOVE``
    func requestMove(to position: SIMD2<Int>) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQUEST_MOVE(position: position)
        mapClient.sendPacket(packet)
    }

    /// Request action on target.
    ///
    /// Send ``PACKET_CZ_REQUEST_ACT``
    func requestAction(_ actionType: DamageType, onTarget targetID: GameObjectID = 0) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQUEST_ACT(targetID: targetID, actionType: actionType)
        mapClient.sendPacket(packet)
    }

    /// Change direction.
    ///
    /// Send ``PACKET_CZ_CHANGE_DIRECTION``
    ///
    /// Receive ``PACKET_ZC_CHANGE_DIRECTION``
    func changeDirection(direction: Direction, headDirection: HeadDirection) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_CHANGE_DIRECTION(
            headDirection: UInt16(headDirection.rawValue),
            direction: UInt8(direction.rawValue)
        )
        mapClient.sendPacket(packet)
    }

    func incrementStatusProperty(_ sp: StatusProperty, by amount: Int) {
        guard let mapClient else {
            return
        }

        switch sp {
        case .str, .agi, .vit, .int, .dex, .luk:
            let packet = PacketFactory.CZ_STATUS_CHANGE(property: sp, amount: amount)
            mapClient.sendPacket(packet)
        case .pow, .sta, .wis, .spl, .con, .crt:
            let packet = PacketFactory.CZ_ADVANCED_STATUS_CHANGE(property: sp, amount: amount)
            mapClient.sendPacket(packet)
        default:
            break
        }
    }

    func upgradeSkillLevel(skillID: Int) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_UPGRADE_SKILLLEVEL(skillID: skillID)
        mapClient.sendPacket(packet)
    }

    func useSkill(skillID: Int, level: Int, onTarget targetID: GameObjectID) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_USE_SKILL(
            skillID: skillID,
            selectedLevel: max(level, 1),
            targetID: targetID
        )
        mapClient.sendPacket(packet)
    }

    func useSkill(skillID: Int, level: Int, toGround position: SIMD2<Int>) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_USE_SKILL_TOGROUND(
            skillID: skillID,
            selectedLevel: max(level, 1),
            position: position
        )
        mapClient.sendPacket(packet)
    }

    func selectWarpPoint(mapName: String) {
        guard let mapClient, let warpList else {
            return
        }

        let packet = PacketFactory.CZ_SELECT_WARPPOINT(skillID: warpList.skillID, mapName: mapName)
        mapClient.sendPacket(packet)

        self.warpList = nil
    }

    func cancelWarpPoint() {
        selectWarpPoint(mapName: "cancel")
    }

    // MARK: - Item

    func pickUpItem(objectID: GameObjectID) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_ITEM_PICKUP(objectID: objectID)
        mapClient.sendPacket(packet)
    }

    func useItem(at index: Int) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_USE_ITEM(index: index, accountID: account.accountID)
        mapClient.sendPacket(packet)
    }

    func equipItem(at index: Int, location: EquipPositions) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQ_WEAR_EQUIP(index: index, location: location)
        mapClient.sendPacket(packet)
    }

    func unequipItem(at index: Int) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_REQ_TAKEOFF_EQUIP(index: index)
        mapClient.sendPacket(packet)
    }

    func throwItem(at index: Int, amount: Int) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_ITEM_THROW(index: index, amount: amount)
        mapClient.sendPacket(packet)
    }

    // MARK: - Shortcut

    func setShortcut(_ shortcut: Shortcut, atRow row: Int, column: Int) {
        guard let mapClient else {
            return
        }

        var shortcutList = self.shortcutList
        shortcutList.setShortcut(shortcut, atRow: row, column: column)

        for change in shortcutList.changes(from: self.shortcutList) {
            let packet = PacketFactory.CZ_SHORTCUT_KEY_CHANGE2(change: change)
            mapClient.sendPacket(packet)
        }

        self.shortcutList = shortcutList
    }

    func removeShortcut(atRow row: Int, column: Int) {
        setShortcut(.empty, atRow: row, column: column)
    }

    func moveShortcut(
        _ shortcut: Shortcut,
        fromRow sourceRow: Int,
        column sourceColumn: Int,
        toRow targetRow: Int,
        column targetColumn: Int
    ) {
        guard let mapClient,
              shortcutList.rows[sourceRow][sourceColumn] == shortcut else {
            return
        }

        var shortcutList = self.shortcutList
        shortcutList.setShortcut(.empty, atRow: sourceRow, column: sourceColumn)
        shortcutList.setShortcut(shortcut, atRow: targetRow, column: targetColumn)

        for change in shortcutList.changes(from: self.shortcutList) {
            let packet = PacketFactory.CZ_SHORTCUT_KEY_CHANGE2(change: change)
            mapClient.sendPacket(packet)
        }

        self.shortcutList = shortcutList
    }

    func setShortcutRowShift(_ rowShift: Int) {
        guard let mapClient else {
            return
        }

        shortcutList.rowShift = rowShift

        let packet = PacketFactory.CZ_SHORTCUTKEYBAR_ROTATE2(rowShift: rowShift)
        mapClient.sendPacket(packet)
    }

    // MARK: - NPC Dialog

    func talkToNPC(npcID: GameObjectID) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_CONTACTNPC(npcID: npcID)
        mapClient.sendPacket(packet)
    }

    func requestNextMessage() {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        let packet = PacketFactory.CZ_REQ_NEXT_SCRIPT(npcID: npcID)
        mapClient.sendPacket(packet)

        dialog?.setNeedsClearMessage()
        dialog?.clearAction()
    }

    func closeDialog() {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        dialog = nil

        let packet = PacketFactory.CZ_CLOSE_DIALOG(npcID: npcID)
        mapClient.sendPacket(packet)
    }

    func selectMenu(_ select: UInt8) {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        dialog?.clearMenu()

        let packet = PacketFactory.CZ_CHOOSE_MENU(npcID: npcID, select: select)
        mapClient.sendPacket(packet)
    }

    func cancelMenu() {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        dialog = nil

        let packet = PacketFactory.CZ_CHOOSE_MENU(npcID: npcID, select: 255)
        mapClient.sendPacket(packet)
    }

    func confirmInput(_ value: Int32) {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        let packet = PacketFactory.CZ_INPUT_EDITDLG(npcID: npcID, value: value)
        mapClient.sendPacket(packet)

        dialog?.clearInput()
    }

    func confirmInput(_ value: String) {
        guard let mapClient, let npcID = dialog?.npcID else {
            return
        }

        let packet = PacketFactory.CZ_INPUT_EDITDLGSTR(npcID: npcID, value: value)
        mapClient.sendPacket(packet)

        dialog?.clearInput()
    }

    // MARK: - NPC Shop

    func selectDealType(_ dealType: NPCShopDealType) {
        guard let mapClient, let npcID = dealSelectionNPCID else {
            return
        }

        dealSelectionNPCID = nil

        let packet = PacketFactory.CZ_ACK_SELECT_DEALTYPE(npcID: npcID, dealType: dealType)
        mapClient.sendPacket(packet)
    }

    func cancelDealSelection() {
        dealSelectionNPCID = nil
    }

    func purchaseItems(_ purchases: [NPCShopPurchase]) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_PC_PURCHASE_ITEMLIST(purchases: purchases)
        mapClient.sendPacket(packet)
    }

    func sellItems(_ sales: [NPCShopSale]) {
        guard let mapClient else {
            return
        }

        let packet = PacketFactory.CZ_PC_SELL_ITEMLIST(sales: sales)
        mapClient.sendPacket(packet)
    }

    func closeNPCShop() {
        guard let mapClient else {
            return
        }

        npcShop = nil

        let packet = PacketFactory.CZ_NPC_TRADE_QUIT()
        mapClient.sendPacket(packet)
    }

    // MARK: - Storage

    func moveItemToStorage(index: Int, amount: Int) {
        guard let mapClient, storage != nil else {
            return
        }

        let packet = PacketFactory.CZ_MOVE_ITEM_FROM_BODY_TO_STORE(index: index, amount: amount)
        mapClient.sendPacket(packet)
    }

    func moveItemFromStorage(index: Int, amount: Int) {
        guard let mapClient, storage != nil else {
            return
        }

        let packet = PacketFactory.CZ_MOVE_ITEM_FROM_STORE_TO_BODY(index: index, amount: amount)
        mapClient.sendPacket(packet)
    }

    func closeStorage() {
        guard let mapClient else {
            return
        }

        storage = nil

        let packet = PacketFactory.CZ_CLOSE_STORE()
        mapClient.sendPacket(packet)
    }
}

extension PlaySession {
    /// An item which is no longer in the inventory is dimmed, and cannot be used.
    func isShortcutAvailable(_ shortcut: Shortcut) -> Bool {
        switch shortcut {
        case .empty, .skill:
            true
        case .item(let itemID):
            inventory.items.values.contains(where: { $0.itemID == itemID })
        }
    }

    /// The number shown beside the icon: how many of an item are left, or the level a skill is used at.
    func shortcutLabel(_ shortcut: Shortcut) -> String? {
        switch shortcut {
        case .empty:
            nil
        case .item(let itemID):
            inventory.items.values.first(where: { $0.itemID == itemID }).map({ "\($0.amount)" })
        case .skill(_, let level):
            "\(level)"
        }
    }

    func skillCooldown(for shortcut: Shortcut) -> SkillCooldown? {
        switch shortcut {
        case .empty, .item:
            nil
        case .skill(let skillID, _):
            skillCooldowns[skillID]
        }
    }
}

extension PlaySession {
    static let testing = PlaySession(context: .testing)

    convenience init(context: GameContext) {
        self.init(
            context: context,
            account: AccountInfo(from: PACKET_AC_ACCEPT_LOGIN()),
            character: CharacterInfo()
        )
    }
}
