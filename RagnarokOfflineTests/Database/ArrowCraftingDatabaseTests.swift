//
//  ArrowCraftingDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2026/10/25.
//

import rAthenaResources
import XCTest
@testable import RagnarokDatabase

final class ArrowCraftingDatabaseTests: XCTestCase {
    func testRenewal() async throws {
        let database = ArrowCraftingDatabase(baseURL: serverResourceBaseURL, mode: .renewal)
        let arrowCraftings = try await database.arrowCraftings()
        XCTAssertEqual(arrowCraftings.count, 136)

        let oldBlueBox = arrowCraftings.first(where: { $0.source == "Old_Blue_Box" })!
        XCTAssertEqual(oldBlueBox.make, [
            ArrowCrafting.Make(item: "Incisive_Arrow", amount: 50),
            ArrowCrafting.Make(item: "Sleep_Arrow", amount: 50),
        ])

        let emperium = arrowCraftings.first(where: { $0.source == "Emperium" })!
        XCTAssertEqual(emperium.make.count, 3)
        XCTAssertEqual(emperium.make[0], ArrowCrafting.Make(item: "Immatrial_Arrow", amount: 600))
    }
}
