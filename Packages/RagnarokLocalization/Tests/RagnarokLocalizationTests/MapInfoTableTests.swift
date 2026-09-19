//
//  MapInfoTableTests.swift
//  RagnarokLocalizationTests
//
//  Created by Leon Li on 2024/5/27.
//

import XCTest
@testable import RagnarokLocalization

final class MapInfoTableTests: XCTestCase {
    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "卢恩·米德加兹王国 首都普隆德拉")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "盧恩 米德加茲王國首都普隆德拉")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera, the Capital of Rune-Midgarts Kingdom")
    }

    func testFrench() async throws {
        let locale = Locale(languageCode: .french)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgard")
    }

    func testGerman() async throws {
        let locale = Locale(languageCode: .german)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgard")
    }

    func testIndonesian() async throws {
        let locale = Locale(languageCode: .indonesian)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgarts")
    }

    func testJapanese() async throws {
        let locale = Locale(languageCode: .japanese)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "ルーンミッドガッツ王国の首都プロンテラ")
    }

    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "룬-미드가츠 왕국 수도 프론테라")
    }

    func testPortuguese() async throws {
        let locale = Locale(languageCode: .portuguese, languageRegion: .brazil)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera")
    }

    func testRussian() async throws {
        let locale = Locale(languageCode: .russian)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Стольный град Пронтера")
    }

    func testSpanish() async throws {
        let locale = Locale(languageCode: .spanish)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera, capital del reino de Rune-Midgarts")
    }

    func testThai() async throws {
        let locale = Locale(languageCode: .thai)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Rune-Midgarts Kingdom Capital, Prontera")
    }

    func testTurkish() async throws {
        let locale = Locale(languageCode: .turkish)
        let mapInfoTable = MapInfoTable(locale: locale)
        let prontera = mapInfoTable.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgard")
    }
}
