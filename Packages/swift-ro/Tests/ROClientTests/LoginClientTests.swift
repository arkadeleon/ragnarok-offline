//
//  LoginClientTests.swift
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
@testable import ROClient

final class LoginClientTests: XCTestCase {

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
                self?.logger.info("\(string)")
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

    func testLogin() async throws {
        let loginClient = LoginClient()

        let expectation = expectation(description: "Login")

        loginClient.onAcceptLogin = { packet in
            XCTAssert(packet.serverList.count == 1)
            expectation.fulfill()
        }
        loginClient.onRefuseLogin = {
            XCTAssert(false)
            expectation.fulfill()
        }
        loginClient.onNotifyBan = {
            XCTAssert(false)
            expectation.fulfill()
        }
        loginClient.onError = { _ in
            XCTAssert(false)
            expectation.fulfill()
        }

        loginClient.connect()

        let username = "ragnarok_m"
        let password = "ragnarok"
        try loginClient.login(username: username, password: password)

        await fulfillment(of: [expectation])
    }
}
