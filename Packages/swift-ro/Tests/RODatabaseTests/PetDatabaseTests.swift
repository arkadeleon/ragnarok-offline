//
//  PetDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/8.
//

import XCTest
import rAthenaResource
@testable import RODatabase

final class PetDatabaseTests: XCTestCase {
    override func setUp() async throws {
        try await ResourceBundle.shared.load()
    }

    func testPrerenewal() async throws {
        let database = PetDatabase.prerenewal

        let poring = try await database.pet(forAegisName: "PORING")!
        XCTAssertEqual(poring.monster, "PORING")
        XCTAssertEqual(poring.tameItem, "Unripe_Apple")
        XCTAssertEqual(poring.eggItem, "Poring_Egg")
        XCTAssertEqual(poring.equipItem, "Backpack")
        XCTAssertEqual(poring.foodItem, "Apple_Juice")
        XCTAssertEqual(poring.fullness, 3)
        XCTAssertEqual(poring.intimacyFed, 50)
        XCTAssertEqual(poring.captureRate, 2000)
        XCTAssertNil(poring.evolution)
    }

    func testRenewal() async throws {
        let database = PetDatabase.renewal

        let poring = try await database.pet(forAegisName: "PORING")!
        XCTAssertEqual(poring.monster, "PORING")
        XCTAssertEqual(poring.tameItem, "Unripe_Apple")
        XCTAssertEqual(poring.eggItem, "Poring_Egg")
        XCTAssertEqual(poring.equipItem, "Backpack")
        XCTAssertEqual(poring.foodItem, "Apple_Juice")
        XCTAssertEqual(poring.fullness, 3)
        XCTAssertEqual(poring.intimacyFed, 50)
        XCTAssertEqual(poring.captureRate, 2000)
        XCTAssertEqual(poring.evolution?[0].target, "MASTERING")
        XCTAssertEqual(poring.evolution?[0].itemRequirements[0].item, "Leaf_Of_Yggdrasil")
        XCTAssertEqual(poring.evolution?[0].itemRequirements[0].amount, 10)
        XCTAssertEqual(poring.evolution?[0].itemRequirements[1].item, "Unripe_Apple")
        XCTAssertEqual(poring.evolution?[0].itemRequirements[1].amount, 3)
    }
}
