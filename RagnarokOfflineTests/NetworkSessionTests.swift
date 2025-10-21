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
@testable import NetworkClient
@testable import NetworkPackets

final class NetworkSessionTests: XCTestCase {
    var account: AccountInfo!
    var charServers: [CharServerInfo]!
    var char: CharInfo!
    var mapServer: MapServerInfo!

    override func setUp() async throws {
        let url = ServerResourceManager.shared.workingDirectoryURL
        if FileManager.default.fileExists(atPath: url.path()) {
            try FileManager.default.removeItem(at: url)
        }

        try await ServerResourceManager.shared.prepareWorkingDirectory()

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

        for await event in loginSession.events {
            if case .loginAccepted(let account, let charServers) = event {
                self.account = account
                self.charServers = charServers
                XCTAssertEqual(charServers.count, 1)
                break
            }
        }

        // MARK: - Start char session

        let charSession = CharSession(account: account, charServer: charServers[0])

        charSession.start()

        for await event in charSession.events {
            if case .charServerAccepted(let chars) = event {
                XCTAssertEqual(chars.count, 0)
                break
            }
        }

        // MARK: - Make a char

        char = CharInfo()
        char.name = "Leon"
        char.str = 1
        char.agi = 1
        char.vit = 1
        char.int = 1
        char.dex = 1
        char.luk = 1
        charSession.makeChar(char: char)

        for await event in charSession.events {
            if case .makeCharAccepted(let char) = event {
                self.char = char
                XCTAssertEqual(char.name, "Leon")
                XCTAssertEqual(char.speed, 150)
                break
            }
        }

        // MARK: - Select a char

        charSession.selectChar(slot: 0)

        for await event in charSession.events {
            if case .charServerNotifiedMapServer(let charID, let mapName, let mapServer) = event {
                self.mapServer = mapServer
                XCTAssertEqual(charID, char.charID)
                break
            }
        }

        // MARK: - Start map session

        let mapSession = MapSession(account: account, char: char, mapServer: mapServer)

        mapSession.start()

        for await event in mapSession.events(for: MapEvents.Changed.self).prefix(1) {
            XCTAssertEqual(event.position, [18, 26])

            // Load map.
            sleep(1)

            mapSession.notifyMapLoaded()
        }

        sleep(1)

        let status = mapSession.status
        XCTAssertEqual(status.str, 1)
        XCTAssertEqual(status.agi, 1)
        XCTAssertEqual(status.vit, 1)
        XCTAssertEqual(status.int, 1)
        XCTAssertEqual(status.dex, 1)
        XCTAssertEqual(status.luk, 1)

        // MARK: - Move to warp

        mapSession.requestMove(to: [27, 30])

        for await event in mapSession.events(for: PlayerEvents.Moved.self).prefix(1) {
            XCTAssertEqual(event.startPosition, [18, 26])
            XCTAssertEqual(event.endPosition, [27, 30])
        }

        for await event in mapSession.events(for: MapEvents.Changed.self).prefix(1) {
            XCTAssertEqual(event.position, [51, 30])

            // Load map.
            sleep(1)

            mapSession.notifyMapLoaded()
        }

        var mapObjects: [MapObject] = []
        for await event in mapSession.events(for: MapObjectEvents.Spawned.self).prefix(4) {
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
