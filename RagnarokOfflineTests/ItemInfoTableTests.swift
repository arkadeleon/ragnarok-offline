//
//  ItemInfoTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/29.
//

import XCTest
@testable import ROResources

final class ItemInfoTableTests: XCTestCase {
    let resourceManager = ResourceManager(
        localURL: Bundle.main.resourceURL!,
        remoteURL: URL(string: "http://127.0.0.1:8080/client")
    )

    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "苹果")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "蘋果")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testFrench() async throws {
        let locale = Locale(languageCode: .french)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testGerman() async throws {
        let locale = Locale(languageCode: .german)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testIndonesian() async throws {
        let locale = Locale(languageCode: .indonesian)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testItalian() async throws {
        let locale = Locale(languageCode: .italian)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testJapanese() async throws {
        let locale = Locale(languageCode: .japanese)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "リンゴ")
    }

    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "사과")
    }

    func testPortuguese() async throws {
        let locale = Locale(languageCode: .portuguese, languageRegion: .brazil)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Maçã")
    }

    func testRussian() async throws {
        let locale = Locale(languageCode: .russian)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Яблоко")
    }

    func testSpanish() async throws {
        let locale = Locale(languageCode: .spanish)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testThai() async throws {
        let locale = Locale(languageCode: .thai)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testTurkish() async throws {
        let locale = Locale(languageCode: .turkish)
        let itemInfoTable = await resourceManager.itemInfoTable(for: locale)
        let apple = itemInfoTable.localizedIdentifiedItemName(forItemID: 512)
        XCTAssertEqual(apple, "Apple")
    }
}
