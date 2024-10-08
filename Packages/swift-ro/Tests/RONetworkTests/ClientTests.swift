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

    var subscriptions = Set<AnyCancellable>()

    override func setUp() async throws {
        let url = ServerResourceManager.default.baseURL
        try FileManager.default.removeItem(at: url)

        try ServerResourceManager.default.prepareForServers()

        NotificationCenter.default.publisher(for: .ServerDidOutputData, object: nil)
            .map { $0.userInfo![ServerOutputDataKey] as! Data }
            .compactMap { data in
                String(data: data, encoding: .isoLatin1)?
                    .replacingOccurrences(of: "\n", with: "\r\n")
            }
            .sink { [weak self] string in
//                self?.logger.info("\(string)")
            }
            .store(in: &subscriptions)

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
        var state = ClientState()
        var charServer: CharServerInfo?
        var mapServer: MapServerInfo?

        // MARK: - Login

        let loginExpectation = expectation(description: "Login")

        loginClient = LoginClient()

        loginClient.subscribe(to: LoginEvents.Accepted.self) { event in
            XCTAssertEqual(event.charServers.count, 1)

            state.accountID = event.accountID
            state.loginID1 = event.loginID1
            state.loginID2 = event.loginID2
            state.sex = event.sex

            charServer = event.charServers[0]

            loginExpectation.fulfill()
        }
        .store(in: &subscriptions)

        loginClient.subscribe(to: LoginEvents.Refused.self) { _ in
            XCTAssert(false)
        }
        .store(in: &subscriptions)

        loginClient.subscribe(to: AuthenticationEvents.Banned.self) { _ in
            XCTAssert(false)
        }
        .store(in: &subscriptions)

        loginClient.subscribe(to: ConnectionEvents.ErrorOccurred.self) { event in
            self.logger.error("\(event.error)")
        }
        .store(in: &subscriptions)

        loginClient.connect()

        let username = "ragnarok_m"
        let password = "ragnarok"
        loginClient.login(username: username, password: password)

        await fulfillment(of: [loginExpectation])

        // MARK: - Enter Char

        let enterCharExpectation = expectation(description: "EnterChar")

        charClient = CharClient(state: state, charServer: charServer!)

        charClient.subscribe(to: CharServerEvents.Accepted.self) { event in
            XCTAssertEqual(event.chars.count, 0)

            enterCharExpectation.fulfill()
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharServerEvents.Refused.self) { _ in
            XCTAssert(false)
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: AuthenticationEvents.Banned.self) { _ in
            XCTAssert(false)
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: ConnectionEvents.ErrorOccurred.self) { event in
            self.logger.error("\(event.error)")
        }
        .store(in: &subscriptions)

        charClient.connect()

        charClient.enter()

        await fulfillment(of: [enterCharExpectation])

        // MARK: - Make Char

        let makeCharExpectation = expectation(description: "MakeChar")

        charClient.subscribe(to: CharEvents.MakeAccepted.self) { event in
            XCTAssertEqual(event.char.name, "Leon")

            makeCharExpectation.fulfill()
        }
        .store(in: &subscriptions)

        charClient.subscribe(to: CharEvents.MakeRefused.self) { _ in
            XCTAssert(false)
        }
        .store(in: &subscriptions)

        var char = CharInfo()
        char.name = "Leon"
        char.str = 1
        char.agi = 1
        char.vit = 1
        char.int = 1
        char.dex = 1
        char.luk = 1
        charClient.makeChar(char: char)

        await fulfillment(of: [makeCharExpectation])

        // MARK: - Select Char

        let selectCharExpectation = expectation(description: "SelectChar")

        charClient.subscribe(to: CharServerEvents.NotifyMapServer.self) { event in
            state.charID = event.charID

            mapServer = event.mapServer

            selectCharExpectation.fulfill()
        }
        .store(in: &subscriptions)

        charClient.selectChar(slot: 0)

        await fulfillment(of: [selectCharExpectation])

        // MARK: - Enter Map

        let enterMapExpectation = expectation(description: "EnterMap")

        mapClient = MapClient(state: state, mapServer: mapServer!)

        mapClient.subscribe(to: MapEvents.Changed.self) { event in
            XCTAssertEqual(event.position, [18, 26])

            // Load map.
            sleep(1)

            self.mapClient.notifyMapLoaded()

            enterMapExpectation.fulfill()
        }
        .store(in: &subscriptions)

        mapClient.subscribe(to: PlayerEvents.StatusPropertyChanged.self) { event in
            print("Status property changed: \(event.sp), \(event.value)")
            switch event.sp {
            case .str, .agi, .vit, .int, .dex, .luk:
                XCTAssertEqual(event.value, 1)
            default:
                break
            }
        }
        .store(in: &subscriptions)

        mapClient.connect()

        mapClient.enter()

        mapClient.keepAlive()

        await fulfillment(of: [enterMapExpectation])

        // MARK: - Request Move

        let requestMoveExpectation = expectation(description: "RequestMove")

        mapClient.subscribe(to: PlayerEvents.Moved.self) { event in
            XCTAssertEqual(event.moveData.x0, 18)
            XCTAssertEqual(event.moveData.y0, 26)
            XCTAssertEqual(event.moveData.x1, 10)
            XCTAssertEqual(event.moveData.y1, 26)

            requestMoveExpectation.fulfill()
        }
        .store(in: &subscriptions)

        mapClient.requestMove(x: 10, y: 26)

        await fulfillment(of: [requestMoveExpectation])
    }
}
