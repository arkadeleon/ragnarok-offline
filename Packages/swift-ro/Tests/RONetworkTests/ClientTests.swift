//
//  ClientTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/8/8.
//

import XCTest
import OSLog
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaResources
import RODatabase
@testable import RONetwork

final class ClientTests: XCTestCase {
    let logger = Logger(subsystem: "RONetworkTests", category: "ClientTests")

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
//                logger.info("\(message)")
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
        var state = ClientState()
        var charServer: CharServerInfo?
        var mapServer: MapServerInfo?

        // MARK: - Login

        let loginSession = LoginSession()

        loginSession.start()

        let username = "ragnarok_m"
        let password = "ragnarok"
        loginSession.login(username: username, password: password)

        for await event in loginSession.eventStream(for: LoginEvents.Accepted.self).prefix(1) {
            XCTAssertEqual(event.charServers.count, 1)

            state.accountID = event.accountID
            state.loginID1 = event.loginID1
            state.loginID2 = event.loginID2
            state.sex = event.sex

            charServer = event.charServers[0]
        }

        // MARK: - Enter char

        let charClient = CharClient(state: state, charServer: charServer!)

        charClient.connect()

        charClient.enter()

        for await event in charClient.eventStream(for: CharServerEvents.Accepted.self).prefix(1) {
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
        charClient.makeChar(char: char)

        for await event in charClient.eventStream(for: CharEvents.MakeAccepted.self).prefix(1) {
            XCTAssertEqual(event.char.name, "Leon")
        }

        // MARK: - Select a char

        charClient.selectChar(slot: 0)

        for await event in charClient.eventStream(for: CharServerEvents.NotifyMapServer.self).prefix(1) {
            state.charID = event.charID

            mapServer = event.mapServer
        }

        // MARK: - Enter map

        let mapClient = MapClient(state: state, mapServer: mapServer!)

        Task {
            for await event in mapClient.eventStream(for: PlayerEvents.StatusPropertyChanged.self) {
                switch event.sp {
                case .str, .agi, .vit, .int, .dex, .luk:
                    XCTAssertEqual(event.value, 1)
                default:
                    break
                }
            }
        }

        var objects: [MapObject] = []
        Task {
            for await event in mapClient.eventStream(for: MapObjectEvents.Spawned.self) {
                objects.append(event.object)
            }
        }

        mapClient.connect()

        mapClient.enter()

        mapClient.keepAlive()

        for await event in mapClient.eventStream(for: MapEvents.Changed.self).prefix(1) {
            XCTAssertEqual(event.position, [18, 26])

            // Load map.
            let map = try await MapDatabase.renewal.map(forName: String(event.mapName.dropLast(4)))!
            let grid = map.grid()!
            XCTAssertEqual(grid.xs, 80)
            XCTAssertEqual(grid.ys, 80)
            XCTAssertTrue(grid.cell(atX: 18, y: 26).isWalkable)

            mapClient.notifyMapLoaded()
        }

        // MARK: - Move to warp

        sleep(1)

        mapClient.requestMove(x: 27, y: 30)

        for await event in mapClient.eventStream(for: PlayerEvents.Moved.self).prefix(1) {
            XCTAssertEqual(event.fromPosition, [18, 26])
            XCTAssertEqual(event.toPosition, [27, 30])
        }

        for await event in mapClient.eventStream(for: MapEvents.Changed.self).prefix(1) {
            XCTAssertEqual(event.position, [51, 30])

            // Load map.
            sleep(1)

            mapClient.notifyMapLoaded()
        }

        // MARK: - Talk to wounded swordsman

        sleep(1)

        let woundedSwordsman1 = objects.first(where: { $0.job == 687 })!
        mapClient.contactNPC(npcID: woundedSwordsman1.id)

        sleep(1)

        let woundedSwordsman2 = objects.first(where: { $0.job == 688 })!
        mapClient.contactNPC(npcID: woundedSwordsman2.id)

        sleep(1)

        mapClient.requestNextScript(npcID: woundedSwordsman2.id)

        sleep(1)

        mapClient.requestNextScript(npcID: woundedSwordsman2.id)

        sleep(1)

        mapClient.closeDialog(npcID: woundedSwordsman2.id)

        sleep(5)
    }
}
