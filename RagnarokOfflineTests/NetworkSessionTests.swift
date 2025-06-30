//
//  NetworkSessionTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/8/8.
//

import XCTest
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaResources
@testable import RONetwork
import ROPackets

final class NetworkSessionTests: XCTestCase {
    var account: AccountInfo!
    var charServers: [CharServerInfo]!
    var char: CharInfo!
    var mapServer: MapServerInfo!

    override func setUp() async throws {
        let url = ServerResourceManager.default.workingDirectoryURL
        if FileManager.default.fileExists(atPath: url.path()) {
            try FileManager.default.removeItem(at: url)
        }

        try ServerResourceManager.default.prepareWorkingDirectory()

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
//        await LoginServer.shared.stop()
//        await CharServer.shared.stop()
//        await MapServer.shared.stop()
    }

    func testNetworkSession() async throws {
        // MARK: - Start login session

        let loginSession = LoginSession(address: "127.0.0.1", port: 6900)

        loginSession.start()

        let username = "ragnarok_m"
        let password = "ragnarok"
        loginSession.login(username: username, password: password)

        for await event in loginSession.eventStream(for: LoginEvents.Accepted.self).prefix(1) {
            account = event.account
            charServers = event.charServers

            XCTAssertEqual(event.charServers.count, 1)
        }

        // MARK: - Start char session

        let charSession = CharSession(account: account, charServer: charServers[0])

        charSession.start()

        for await event in charSession.eventStream(for: CharServerEvents.Accepted.self).prefix(1) {
            XCTAssertEqual(event.chars.count, 0)
        }

        // MARK: - Make a char

        var char = CharInfo()
        char.name = "Leon"
        char.str = 1
        char.agi = 1
        char.vit = 1
        char.int = 1
        char.dex = 1
        char.luk = 1
        charSession.makeChar(char: char)

        for await event in charSession.eventStream(for: CharEvents.MakeAccepted.self).prefix(1) {
            char = event.char
            XCTAssertEqual(event.char.name, "Leon")
            XCTAssertEqual(event.char.speed, 150)
        }

        // MARK: - Select a char

        charSession.selectChar(slot: 0)

        for await event in charSession.eventStream(for: CharServerEvents.NotifyMapServer.self).prefix(1) {
            mapServer = event.mapServer

            XCTAssertEqual(event.charID, char.charID)
        }

        // MARK: - Start map session

        let mapSession = MapSession(account: account, char: char, mapServer: mapServer)

        mapSession.start()

        for await event in mapSession.eventStream(for: MapEvents.Changed.self).prefix(1) {
            XCTAssertEqual(event.position, [18, 26])

            // Load map.
            sleep(1)

            mapSession.notifyMapLoaded()
        }

        sleep(1)

        let player = mapSession.player
        XCTAssertEqual(player.status.str, 1)
        XCTAssertEqual(player.status.agi, 1)
        XCTAssertEqual(player.status.vit, 1)
        XCTAssertEqual(player.status.int, 1)
        XCTAssertEqual(player.status.dex, 1)
        XCTAssertEqual(player.status.luk, 1)

        // MARK: - Move to warp

        mapSession.requestMove(to: [27, 30])

        for await event in mapSession.eventStream(for: PlayerEvents.Moved.self).prefix(1) {
            XCTAssertEqual(event.fromPosition, [18, 26])
            XCTAssertEqual(event.toPosition, [27, 30])
        }

        for await event in mapSession.eventStream(for: MapEvents.Changed.self).prefix(1) {
            XCTAssertEqual(event.position, [51, 30])

            // Load map.
            sleep(1)

            mapSession.notifyMapLoaded()
        }

        var mapObjects: [MapObject] = []
        for await event in mapSession.eventStream(for: MapObjectEvents.Spawned.self).prefix(4) {
            mapObjects.append(event.object)
        }

        // MARK: - Talk to wounded swordsman

        sleep(1)

        let woundedSwordsman1 = mapObjects.first(where: { $0.job == 687 })!
        mapSession.talkToNPC(objectID: woundedSwordsman1.objectID)

        sleep(1)

        let woundedSwordsman2 = mapObjects.first(where: { $0.job == 688 })!
        mapSession.talkToNPC(objectID: woundedSwordsman2.objectID)

        sleep(1)

        mapSession.requestNextMessage(objectID: woundedSwordsman2.objectID)

        sleep(1)

        mapSession.requestNextMessage(objectID: woundedSwordsman2.objectID)

        sleep(1)

        mapSession.closeDialog(objectID: woundedSwordsman2.objectID)

        sleep(5)
    }
}
