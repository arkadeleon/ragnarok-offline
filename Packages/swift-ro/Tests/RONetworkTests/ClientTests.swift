//
//  ClientTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/8/8.
//

import XCTest
import Combine
import OSLog
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaResources
@testable import RONetwork

final class ClientTests: XCTestCase {
    let logger = Logger(subsystem: "RONetworkTests", category: "ClientTests")

    var loginClient: LoginClient!
    var charClient: CharClient!
    var mapClient: MapClient!

    var subscription: AnyCancellable?

    override func setUp() async throws {
        let url = ServerResourceBundle.shared.url
        try FileManager.default.removeItem(at: url)

        try await ServerResourceBundle.shared.load()

        subscription = NotificationCenter.default.publisher(for: .ServerDidOutputData, object: nil)
            .map { $0.userInfo![ServerOutputDataKey] as! Data }
            .compactMap { data in
                String(data: data, encoding: .isoLatin1)?
                    .replacingOccurrences(of: "\n", with: "\r\n")
            }
            .sink { [weak self] string in
//                self?.logger.info("\(string)")
            }

        await LoginServer.shared.start()
        await CharServer.shared.start()
        await MapServer.shared.start()

        // Wait char server connect to login server.
        try await Task.sleep(for: .seconds(1))
    }

    override func tearDown() async throws {
//        await LoginServer.shared.stop()
//        await CharServer.shared.stop()
//        await MapServer.shared.stop()
    }

    func testClient() async throws {
        var _state: ClientState?
        var _charServer: CharServerInfo?
        var _mapServer: MapServerInfo?

        // MARK: - Login

        let loginExpectation = expectation(description: "Login")

        loginClient = LoginClient()

        loginClient.connect()

        loginClient.onAcceptLogin = { state, charServers in
            XCTAssert(charServers.count == 1)

            _state = state
            _charServer = charServers[0]

            loginExpectation.fulfill()
        }

        loginClient.onRefuseLogin = { message in
            XCTAssert(false)
        }

        loginClient.onNotifyBan = { message in
            XCTAssert(false)
        }

        loginClient.onError = { error in
            self.logger.error("\(error)")
        }

        let username = "ragnarok_m"
        let password = "ragnarok"
        loginClient.login(username: username, password: password)

        await fulfillment(of: [loginExpectation])

        // MARK: - Enter Char

        let enterCharExpectation = expectation(description: "EnterChar")

        charClient = CharClient(state: _state!, charServer: _charServer!)

        charClient.connect()

        charClient.onAcceptEnter = { charServers in
            XCTAssert(charServers.count == 0)

            enterCharExpectation.fulfill()
        }

        charClient.onRefuseEnter = {
            XCTAssert(false)
        }

        charClient.onError = { error in
            self.logger.error("\(error)")
        }

        charClient.enter()

        await fulfillment(of: [enterCharExpectation])

        // MARK: - Make Char

        let makeCharExpectation = expectation(description: "MakeChar")

        charClient.onAcceptMakeChar = {
            makeCharExpectation.fulfill()
        }

        charClient.onRefuseMakeChar = {
            XCTAssert(false)
        }

        charClient.makeChar(name: "Leon", str: 1, agi: 1, vit: 1, int: 1, dex: 1, luk: 1)

        await fulfillment(of: [makeCharExpectation])

        // MARK: - Select Char

        let selectCharExpectation = expectation(description: "SelectChar")

        charClient.onNotifyZoneServer = { mapName, mapServer in
            _mapServer = mapServer

            selectCharExpectation.fulfill()
        }

        charClient.selectChar(slot: 0)

        await fulfillment(of: [selectCharExpectation])

        // MARK: - Enter Map

        let enterMapExpectation = expectation(description: "EnterMap")

        mapClient = MapClient(state: _state!, mapServer: _mapServer!)

        mapClient.connect()

        mapClient.onAcceptEnter = {
            enterMapExpectation.fulfill()
        }

        mapClient.onStatusPropertyChanged = { sp, value, value2 in
            print("Status property changed: \(sp), \(value)")
            switch sp {
            case .str, .agi, .vit, .int, .dex, .luk:
                XCTAssertEqual(value, 1)
            default:
                break
            }
        }

        mapClient.enter()

        mapClient.keepAlive()

        await fulfillment(of: [enterMapExpectation])

        // MARK: - Request Move

        try await Task.sleep(for: .seconds(1))

        let requestMoveExpectation = expectation(description: "RequestMove")

        mapClient.onNotifyPlayerMove = { moveData in
            XCTAssertEqual(moveData.x0, 18)
            XCTAssertEqual(moveData.y0, 26)
            XCTAssertEqual(moveData.x1, 10)
            XCTAssertEqual(moveData.y1, 26)

            requestMoveExpectation.fulfill()
        }

        mapClient.requestMove(x: 10, y: 26)

        await fulfillment(of: [requestMoveExpectation])
    }
}
