//
//  ItemProduceDatabaseTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2026/10/25.
//

import rAthenaResources
import XCTest
@testable import RagnarokDatabase

final class ItemProduceDatabaseTests: XCTestCase {
    func testPrerenewal() async throws {
        let database = ItemProduceDatabase(baseURL: serverResourceBaseURL, mode: .prerenewal)
        let itemProduces = try await database.itemProduces()
        XCTAssertEqual(itemProduces.count, 258)

        let sword = itemProduces.first(where: { $0.id == 0 })!
        XCTAssertEqual(sword.productID, 1101)
        XCTAssertEqual(sword.itemLevel, 1)
        XCTAssertEqual(sword.skillID, 99)
        XCTAssertEqual(sword.skillLevel, 1)
        XCTAssertEqual(sword.materials, [ItemProduce.Material(itemID: 998, amount: 2)])

        let dish = itemProduces.first(where: { $0.id == 52 })!
        XCTAssertEqual(dish.productID, 12041)
        XCTAssertEqual(dish.itemLevel, 11)
        XCTAssertEqual(dish.skillID, 0)
        XCTAssertEqual(dish.skillLevel, 0)
        XCTAssertEqual(dish.materials.count, 4)
        XCTAssertEqual(dish.materials[0], ItemProduce.Material(itemID: 7472, amount: 0))
    }

    func testRenewal() async throws {
        let database = ItemProduceDatabase(baseURL: serverResourceBaseURL, mode: .renewal)
        let itemProduces = try await database.itemProduces()
        XCTAssertEqual(itemProduces.count, 293)

        let mineBottle = itemProduces.first(where: { $0.id == 131 })!
        XCTAssertEqual(mineBottle.productID, 7138)
        XCTAssertEqual(mineBottle.itemLevel, 22)
        XCTAssertEqual(mineBottle.skillID, 228)
        XCTAssertEqual(mineBottle.skillLevel, 1)
        XCTAssertEqual(mineBottle.materials, [
            ItemProduce.Material(itemID: 7131, amount: 0),
            ItemProduce.Material(itemID: 713, amount: 1),
            ItemProduce.Material(itemID: 1050, amount: 1),
            ItemProduce.Material(itemID: 1051, amount: 1),
        ])

        let noviceRedPotion = itemProduces.first(where: { $0.id == 271 })!
        XCTAssertEqual(noviceRedPotion.productID, 569)
        XCTAssertEqual(noviceRedPotion.itemLevel, 30)
        XCTAssertEqual(noviceRedPotion.skillID, 0)
        XCTAssertEqual(noviceRedPotion.materials.count, 3)
    }
}
