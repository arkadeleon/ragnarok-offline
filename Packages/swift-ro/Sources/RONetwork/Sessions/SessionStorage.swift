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
    }

    func updateMap(with mapName: String, position: SIMD2<Int16>) {
        self.mapName = mapName
        self.player = Player(position: position)
        self.mapObjects.removeAll()
    }

    func updatePlayerPosition(_ position: SIMD2<Int16>) {
        player?.position = position
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

    func updateMapObjectState(with packet: PACKET_ZC_STATE_CHANGE) -> MapObject? {
        guard var object = mapObjects[packet.AID] else {
            return nil
        }

        object.updateState(with: packet)
        mapObjects[packet.AID] = object

        return object
    }
}
