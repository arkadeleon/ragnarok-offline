//
//  SessionStorage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import ROConstants
import RONetwork

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

    func updateMapServer(with mapName: String, mapServer: MapServerInfo, charID: UInt32) {
        self.charID = charID
        self.mapName = mapName
        self.mapServer = mapServer

        player = Player()
    }

    func updateMap(with mapName: String, position: SIMD2<Int16>) {
        self.mapName = mapName
        player?.position = position
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
}
