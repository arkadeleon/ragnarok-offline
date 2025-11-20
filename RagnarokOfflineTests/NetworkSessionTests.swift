//
//  NetworkSessionTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/8/8.
//

import rAthenaChar
import rAthenaLogin
import rAthenaMap
import rAthenaResources
import XCTest
@testable import RagnarokNetwork

final class NetworkSessionTests: XCTestCase {
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
            if case .charServerAccepted(let characters) = event {
                XCTAssertEqual(characters.count, 0)
                break
            }
        }

        // MARK: - Make a character

        character = CharacterInfo()
        character.name = "Leon"
        character.str = 1
        character.agi = 1
        character.vit = 1
        character.int = 1
        character.dex = 1
        character.luk = 1
        charSession.makeCharacter(character: character)

        for await event in charSession.events {
            if case .makeCharacterAccepted(let character) = event {
                self.character = character
                XCTAssertEqual(character.name, "Leon")
                XCTAssertEqual(character.speed, 150)
                break
            }
        }

        // MARK: - Select a character

        charSession.selectCharacter(slot: 0)

        for await event in charSession.events {
            if case .charServerNotifiedMapServer(let charID, let mapName, let mapServer) = event {
                self.mapServer = mapServer
                XCTAssertEqual(charID, character.charID)
                break
            }
        }

        // MARK: - Start map session

        let mapSession = MapSession(account: account, character: character, mapServer: mapServer)

        mapSession.start()

        for await event in mapSession.events {
            if case .mapChanged(let mapName, let position) = event {
                XCTAssertEqual(position, [18, 26])

                // Load map.
                sleep(1)

                mapSession.notifyMapLoaded()

                break
            }
        }

        sleep(1)

        let status = mapSession.playerStatus
        XCTAssertEqual(status.str, 1)
        XCTAssertEqual(status.agi, 1)
        XCTAssertEqual(status.vit, 1)
        XCTAssertEqual(status.int, 1)
        XCTAssertEqual(status.dex, 1)
        XCTAssertEqual(status.luk, 1)

        // MARK: - Move to warp

        mapSession.requestMove(to: [27, 30])

        for await event in mapSession.events {
            if case .playerMoved(let startPosition, let endPosition) = event {
                XCTAssertEqual(startPosition, [18, 26])
                XCTAssertEqual(endPosition, [27, 30])
                break
            }
        }

        for await event in mapSession.events {
            if case .mapChanged(let mapName, let position) = event {
                XCTAssertEqual(position, [51, 30])

                // Load map.
                sleep(1)

                mapSession.notifyMapLoaded()

                break
            }
        }

        var mapObjects: [MapObject] = []
        for await event in mapSession.events {
            if case .mapObjectSpawned(let object, let position, let direction, let headDirection) = event {
                mapObjects.append(object)

                if mapObjects.count == 4 {
                    break
                }
            }
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
