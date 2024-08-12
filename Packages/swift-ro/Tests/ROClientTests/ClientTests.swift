//
//  ClientTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/8/8.
//

import XCTest
import Combine
import OSLog
import rAthenaResources
import rAthenaLogin
import rAthenaChar
import RONetwork
@testable import ROClient

final class ClientTests: XCTestCase {

    let logger = Logger(subsystem: "ROClientTests", category: "LoginClientTests")

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

        // Wait char server connect to login server.
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
    }

    override func tearDown() async throws {
//        await LoginServer.shared.stop()
//        await CharServer.shared.stop()
    }

    func testClient() async throws {
        let loginExpectation = expectation(description: "Login")
        let charExpectation = expectation(description: "Char")

        var _state = ClientState()
        var _serverInfo: ServerInfo?

        let loginClient = LoginClient()
        loginClient.onAcceptLogin = { state, serverInfoList in
            XCTAssert(serverInfoList.count == 1)

            _state = state
            _serverInfo = serverInfoList[0]

            loginExpectation.fulfill()
        }
        loginClient.onRefuseLogin = { message in
            XCTAssert(false)
            loginExpectation.fulfill()
        }
        loginClient.onNotifyBan = { message in
            XCTAssert(false)
            loginExpectation.fulfill()
        }
        loginClient.onError = { error in
            self.logger.error("\(error)")
        }

        loginClient.connect()

        let username = "ragnarok_m"
        let password = "ragnarok"
        loginClient.login(username: username, password: password)

        await fulfillment(of: [loginExpectation])

        guard let _serverInfo else {
            return
        }

        let charClient = CharClient(state: _state, serverInfo: _serverInfo)
        charClient.onAcceptEnter = { charList in
            XCTAssert(charList.count == 0)

            charExpectation.fulfill()
        }
        charClient.onRefuseEnter = {
            XCTAssert(false)
            charExpectation.fulfill()
        }
        charClient.onError = { error in
            self.logger.error("\(error)")
        }

        charClient.connect()

        charClient.enter()

        await fulfillment(of: [charExpectation])
    }
}
