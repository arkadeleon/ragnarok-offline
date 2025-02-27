//
//  GameSessionTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/8/8.
//

import XCTest
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaResources
import RODatabase
import RONetwork
@testable import ROGame

final class GameSessionTests: XCTestCase {
    override func setUp() async throws {
        let url = ServerResourceManager.default.workingDirectoryURL
        try FileManager.default.removeItem(at: url)

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

    func testClient() async throws {
        let storage = SessionStorage()

        // MARK: - Start login session

        let loginSession = LoginSession(storage: storage, address: "127.0.0.1", port: 6900)

        loginSession.start()

        let username = "ragnarok_m"
        let password = "ragnarok"
        loginSession.login(username: username, password: password)

        for await event in loginSession.eventStream(for: LoginEvents.Accepted.self).prefix(1) {
            XCTAssertEqual(event.charServers.count, 1)
        }

        // MARK: - Start char session

        let charServer = await storage.charServers[0]
        let charSession = CharSession(storage: storage, charServer: charServer)

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
            XCTAssertEqual(event.char.name, "Leon")
        }

        // MARK: - Select a char

        charSession.selectChar(slot: 0)

        for await event in charSession.eventStream(for: CharServerEvents.NotifyMapServer.self).prefix(1) {
            XCTAssertEqual(event.charID, 1)
        }

        // MARK: - Start map session

        let mapServer = await storage.mapServer!
        let mapSession = MapSession(storage: storage, mapServer: mapServer)

        mapSession.start()

        for await event in mapSession.eventStream(for: MapEvents.Changed.self).prefix(1) {
            XCTAssertEqual(event.position, [18, 26])

            // Load map.
            let map = await MapDatabase.renewal.map(forName: String(event.mapName.dropLast(4)))!
            let grid = map.grid()!
            XCTAssertEqual(grid.xs, 80)
            XCTAssertEqual(grid.ys, 80)
            XCTAssertTrue(grid.cell(atX: 18, y: 26).isWalkable)

            mapSession.notifyMapLoaded()
        }

        sleep(1)

        let player = await storage.player!
        XCTAssertEqual(player.status.str, 1)
        XCTAssertEqual(player.status.agi, 1)
        XCTAssertEqual(player.status.vit, 1)
        XCTAssertEqual(player.status.int, 1)
        XCTAssertEqual(player.status.dex, 1)
        XCTAssertEqual(player.status.luk, 1)

        // MARK: - Move to warp

        mapSession.requestMove(x: 27, y: 30)

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

        // MARK: - Talk to wounded swordsman

        sleep(1)

        let woundedSwordsman1 = await storage.mapObjects.values.first(where: { $0.job == 687 })!
        mapSession.talkToNPC(npcID: woundedSwordsman1.id)

        sleep(1)

        let woundedSwordsman2 = await storage.mapObjects.values.first(where: { $0.job == 688 })!
        mapSession.talkToNPC(npcID: woundedSwordsman2.id)

        sleep(1)

        mapSession.requestNextMessage(npcID: woundedSwordsman2.id)

        sleep(1)

        mapSession.requestNextMessage(npcID: woundedSwordsman2.id)

        sleep(1)

        mapSession.closeDialog(npcID: woundedSwordsman2.id)

        sleep(5)
    }
}
