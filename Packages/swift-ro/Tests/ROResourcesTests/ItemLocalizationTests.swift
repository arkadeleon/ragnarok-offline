//
//  ItemLocalizationTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/29.
//

import XCTest
@testable import ROResources

final class ItemLocalizationTests: XCTestCase {
    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "苹果")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "蘋果")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testFrench() async throws {
        let locale = Locale(languageCode: .french)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testGerman() async throws {
        let locale = Locale(languageCode: .german)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testIndonesian() async throws {
        let locale = Locale(languageCode: .indonesian)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testItalian() async throws {
        let locale = Locale(languageCode: .italian)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testJapanese() async throws {
        let locale = Locale(languageCode: .japanese)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "リンゴ")
    }

    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "사과")
    }

    func testPortuguese() async throws {
        let locale = Locale(languageCode: .portuguese, languageRegion: .brazil)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Maçã")
    }

    func testRussian() async throws {
        let locale = Locale(languageCode: .russian)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Яблоко")
    }

    func testSpanish() async throws {
        let locale = Locale(languageCode: .spanish)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testThai() async throws {
        let locale = Locale(languageCode: .thai)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Apple")
    }

    func testTurkish() async throws {
        let locale = Locale(languageCode: .turkish)
        let itemLocalization = ItemLocalization(locale: locale)
        let apple = await itemLocalization.localizedName(for: 512)
        XCTAssertEqual(apple, "Apple")
    }
}
