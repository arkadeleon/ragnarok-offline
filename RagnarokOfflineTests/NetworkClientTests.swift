//
//  NetworkClientTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/8/8.
//

import rAthenaChar
import rAthenaLogin
import rAthenaMap
import rAthenaResources
import XCTest
@testable import RagnarokModels
@testable import RagnarokNetwork
@testable import RagnarokPackets

final class NetworkClientTests: XCTestCase {
    var account: AccountInfo!
    var charServers: [CharServerInfo]!
    var character: CharacterInfo!
    var mapServer: MapServerInfo!

    override func setUp() async throws {
        let workingDirectoryURL = URL.libraryDirectory.appending(path: "rathena.testing", directoryHint: .isDirectory)

        if FileManager.default.fileExists(atPath: workingDirectoryURL.path()) {
            try FileManager.default.removeItem(at: workingDirectoryURL)
        }

        let serverResourceManager = ServerResourceManager()
        try await serverResourceManager.prepareWorkingDirectory(at: workingDirectoryURL)

        Task {
            let messages = NotificationCenter.default.notifications(named: .ServerDidOutputData)
                .map { notification in
                    notification.userInfo![ServerOutputDataKey] as! Data
                }
                .compactMap { data in
                    String(data: data, encoding: .isoLatin1)?
                        .replacingOccurrences(of: "\n", with: "\r\n")
                }
            for await message in messages {
//                print("\(message)")
            }
        }

        async let login = LoginServer.shared.start()
        async let char = CharServer.shared.start()
        async let map = MapServer.shared.start()
        _ = await (login, char, map)

        // Wait char server connect to login server.
        try await Task.sleep(for: .seconds(1))
    }

    override func tearDown() async throws {
        async let login = LoginServer.shared.stop()
        async let char = CharServer.shared.stop()
        async let map = MapServer.shared.stop()
        _ = await (login, char, map)
    }

    func testNetworkClient() async throws {
        // MARK: - Start login client

        let loginClient = Client(name: "Login", address: "127.0.0.1", port: 6900)

        loginClient.connect()

        loginClient.sendPacket({
            var packet = PACKET_CA_LOGIN()
            packet.packetType = HEADER_CA_LOGIN
            packet.version = 0
            packet.username = "ragnarok_m"
            packet.password = "ragnarok"
            packet.clienttype = 0
            return packet
        }())

        loginClient.receivePacket()

        for await packet in loginClient.packetStream {
            if let packet = packet as? PACKET_AC_ACCEPT_LOGIN {
                account = AccountInfo(from: packet)
                charServers = packet.char_servers.map(CharServerInfo.init(from:))
                XCTAssertEqual(charServers.count, 1)
                break
            }
        }

        loginClient.disconnect()

        // MARK: - Connect char server

        let charClient = Client(name: "Char", address: charServers[0].ip, port: charServers[0].port)

        charClient.connect()

        charClient.sendPacket({
            var packet = PACKET_CH_ENTER()
            packet.packetType = HEADER_CH_ENTER
            packet.accountID = account.accountID
            packet.loginID1 = account.loginID1
            packet.loginID2 = account.loginID2
            packet.clientType = account.langType
            packet.sex = UInt8(account.sex)
            return packet
        }())

        charClient.receiveDataAndPacket(count: 4) { data in
//            let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
//            self.account.update(accountID: accountID)
        }

        for await packet in charClient.packetStream {
            if let packet = packet as? PACKET_HC_ACCEPT_ENTER {
                XCTAssertEqual(packet.characters.count, 0)
                break
            }
        }

        // MARK: - Make a character

        charClient.sendPacket({
            var packet = PACKET_CH_MAKE_CHAR()
            packet.packetType = HEADER_CH_MAKE_CHAR
            packet.name = "Leon"
            packet.slot = 0
            packet.hair_color = 0
            packet.hair_style = 0
            packet.job = 0
            packet.sex = 0
            return packet
        }())

        for await packet in charClient.packetStream {
            if let packet = packet as? PACKET_HC_ACCEPT_MAKECHAR {
                character = CharacterInfo(from: packet.character)
                XCTAssertEqual(character.name, "Leon")
                XCTAssertEqual(character.speed, 150)
                break
            }
        }

        // MARK: - Select a character

        charClient.sendPacket({
            var packet = PACKET_CH_SELECT_CHAR()
            packet.packetType = HEADER_CH_SELECT_CHAR
            packet.slot = 0
            return packet
        }())

        for await packet in charClient.packetStream {
            if let packet = packet as? PACKET_HC_NOTIFY_ZONESVR {
                mapServer = MapServerInfo(from: packet)
                XCTAssertEqual(packet.CID, character.charID)
                break
            }
        }

        charClient.disconnect()

        // MARK: - Connect map server

        let mapClient = Client(name: "Map", address: mapServer.ip, port: mapServer.port)

        mapClient.connect()

        mapClient.sendPacket({
            var packet = PACKET_CZ_ENTER()
            packet.accountID = account.accountID
            packet.charID = character.charID
            packet.loginID1 = account.loginID1
            packet.clientTime = UInt32(Date.now.timeIntervalSince1970)
            packet.sex = UInt8(account.sex)
            return packet
        }())

        mapClient.receiveDataAndPacket(count: 4) { data in
//            let accountID = data.withUnsafeBytes({ $0.load(as: UInt32.self) })
//            self.account.update(accountID: accountID)
        }

        for await packet in mapClient.packetStream {
            if let packet = packet as? PACKET_ZC_NPCACK_MAPMOVE {
                XCTAssertEqual(packet.xPos, 18)
                XCTAssertEqual(packet.yPos, 26)

                // Load map.
                try await Task.sleep(for: .seconds(1))

                mapClient.sendPacket({
                    var packet = PACKET_CZ_NOTIFY_ACTORINIT()
                    packet.packetType = HEADER_CZ_NOTIFY_ACTORINIT
                    return packet
                }())

                break
            }
        }

        for await packet in mapClient.packetStream {
            if let packet = packet as? PACKET_ZC_STATUS {
                XCTAssertEqual(packet.str, 1)
                XCTAssertEqual(packet.agi, 1)
                XCTAssertEqual(packet.vit, 1)
                XCTAssertEqual(packet.int_, 1)
                XCTAssertEqual(packet.dex, 1)
                XCTAssertEqual(packet.luk, 1)
                break
            }
        }

        try await Task.sleep(for: .seconds(1))

        // MARK: - Move to warp

        mapClient.sendPacket({
            var packet = PACKET_CZ_REQUEST_MOVE()
            packet.x = 27
            packet.y = 30
            return packet
        }())

        for await packet in mapClient.packetStream {
            if let packet = packet as? PACKET_ZC_NOTIFY_PLAYERMOVE {
                let moveData = MoveData(from: packet.moveData)
                XCTAssertEqual(moveData.startPosition, [18, 26])
                XCTAssertEqual(moveData.endPosition, [27, 30])
                break
            }
        }

        for await packet in mapClient.packetStream {
            if let packet = packet as? PACKET_ZC_NPCACK_MAPMOVE {
                XCTAssertEqual(packet.xPos, 51)
                XCTAssertEqual(packet.yPos, 30)

                // Load map.
                try await Task.sleep(for: .seconds(1))

                mapClient.sendPacket({
                    var packet = PACKET_CZ_NOTIFY_ACTORINIT()
                    packet.packetType = HEADER_CZ_NOTIFY_ACTORINIT
                    return packet
                }())

                break
            }
        }

        var mapObjects: [MapObject] = []

        for await packet in mapClient.packetStream {
            if let packet = packet as? packet_idle_unit {
                let object = MapObject(from: packet)
                mapObjects.append(object)
            }

            if mapObjects.count == 4 {
                break
            }
        }

        // MARK: - Talk to wounded swordsman

        try await Task.sleep(for: .seconds(1))

        let woundedSwordsman1 = mapObjects.first(where: { $0.job == 687 })!

        mapClient.sendPacket({
            var packet = PACKET_CZ_CONTACTNPC()
            packet.packetType = HEADER_CZ_CONTACTNPC
            packet.AID = woundedSwordsman1.objectID
            packet.type = 1
            return packet
        }())

        try await Task.sleep(for: .seconds(1))

        let woundedSwordsman2 = mapObjects.first(where: { $0.job == 688 })!

        mapClient.sendPacket({
            var packet = PACKET_CZ_CONTACTNPC()
            packet.packetType = HEADER_CZ_CONTACTNPC
            packet.AID = woundedSwordsman2.objectID
            packet.type = 1
            return packet
        }())

        try await Task.sleep(for: .seconds(1))

        mapClient.sendPacket({
            var packet = PACKET_CZ_REQ_NEXT_SCRIPT()
            packet.packetType = HEADER_CZ_REQ_NEXT_SCRIPT
            packet.npcID = woundedSwordsman2.objectID
            return packet
        }())

        try await Task.sleep(for: .seconds(1))

        mapClient.sendPacket({
            var packet = PACKET_CZ_REQ_NEXT_SCRIPT()
            packet.packetType = HEADER_CZ_REQ_NEXT_SCRIPT
            packet.npcID = woundedSwordsman2.objectID
            return packet
        }())

        try await Task.sleep(for: .seconds(1))

        mapClient.sendPacket({
            var packet = PACKET_CZ_CLOSE_DIALOG()
            packet.packetType = HEADER_CZ_CLOSE_DIALOG
            packet.GID = woundedSwordsman2.objectID
            return packet
        }())

        try await Task.sleep(for: .seconds(5))

        mapClient.disconnect()
    }
}
