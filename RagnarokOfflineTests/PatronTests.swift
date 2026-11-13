//
//  PatronTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2026/11/12.
//

import rAthenaCommon
import StoreKit
import StoreKitTest
import XCTest
@testable import RagnarokOffline

final class PatronTests: XCTestCase {
    @MainActor
    func testSubscriptionLifecyclePreservesServerMode() async throws {
        let configurationURL = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "RagOff", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: configurationURL)
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        defer {
            session.clearTransactions()
        }

        let suiteName = "PatronTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        // Existing users retain their choice without a subscription, even on launch.
        defaults.set(ServerMode.prerenewal.rawValue, forKey: "server.mode")
        let settings = SettingsModel(defaults: defaults)
        let patron = settings.patron
        try await waitForSubscription(false, patron: patron)
        XCTAssertFalse(patron.hasActiveSubscription)
        XCTAssertEqual(settings.serverMode, .prerenewal)

        let monthly = try await session.buyProduct(identifier: PatronModel.productIDs[0])
        await monthly.finish()
        try await waitForSubscription(true, patron: patron)
        XCTAssertTrue(patron.hasActiveSubscription)
        settings.serverMode = .renewal
        XCTAssertEqual(settings.serverMode, .renewal)

        try session.disableAutoRenewForTransaction(identifier: UInt(monthly.id))
        try await waitForSubscription(true, patron: patron)
        XCTAssertTrue(patron.hasActiveSubscription, "Cancelling renewal keeps access until expiry")

        try session.expireSubscription(productIdentifier: PatronModel.productIDs[0])
        try await waitForSubscription(false, patron: patron)
        XCTAssertFalse(patron.hasActiveSubscription)
        XCTAssertEqual(settings.serverMode, .renewal)
        XCTAssertEqual(defaults.integer(forKey: "server.mode"), ServerMode.renewal.rawValue)
        let relaunchedSettings = SettingsModel(defaults: defaults)
        XCTAssertEqual(relaunchedSettings.serverMode, .renewal)

        let yearly = try await session.buyProduct(identifier: PatronModel.productIDs[1])
        await yearly.finish()
        try await waitForSubscription(true, patron: patron)
        XCTAssertTrue(patron.hasActiveSubscription)
        settings.serverMode = .prerenewal
        XCTAssertEqual(settings.serverMode, .prerenewal)

        try session.refundTransaction(identifier: UInt(yearly.id))
        try await waitForSubscription(false, patron: patron)
        XCTAssertFalse(patron.hasActiveSubscription)
        XCTAssertEqual(settings.serverMode, .prerenewal)
    }

    @MainActor
    private func waitForSubscription(_ expected: Bool, patron: PatronModel, file: StaticString = #filePath, line: UInt = #line) async throws {
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        repeat {
            await patron.refreshEntitlements()
            if patron.hasActiveSubscription == expected {
                return
            }
            try await Task.sleep(for: .milliseconds(50))
        } while ContinuousClock.now < deadline
        XCTAssertEqual(patron.hasActiveSubscription, expected, file: file, line: line)
    }
}
