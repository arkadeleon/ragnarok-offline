//
//  MapNameTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/27.
//

import XCTest
@testable import ROResources

final class MapNameTableTests: XCTestCase {
    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "卢恩 米德加兹王国 首都 普隆德拉")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "盧恩 米德加茲王國 首都 普隆德拉")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgarts")
    }

    func testFrench() async throws {
        let locale = Locale(languageCode: .french)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgard")
    }

    func testGerman() async throws {
        let locale = Locale(languageCode: .german)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgard")
    }

    func testIndonesian() async throws {
        let locale = Locale(languageCode: .indonesian)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Kota Prontera")
    }

    func testItalian() async throws {
        let locale = Locale(languageCode: .italian)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgard")
    }

    func testJapanese() async throws {
        let locale = Locale(languageCode: .japanese)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "ルーンミッドガッツ王国の首都プロンテラ")
    }

    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "룬미드가츠 왕국 수도 프론테라")
    }

    func testPortuguese() async throws {
        let locale = Locale(languageCode: .portuguese, languageRegion: .brazil)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera")
    }

    func testRussian() async throws {
        let locale = Locale(languageCode: .russian)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Стольный град Пронтера")
    }

    func testSpanish() async throws {
        let locale = Locale(languageCode: .spanish)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgard")
    }

    func testThai() async throws {
        let locale = Locale(languageCode: .thai)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgarts")
    }

    func testTurkish() async throws {
        let locale = Locale(languageCode: .turkish)
        let mapLocalization = MapNameTable(locale: locale)
        let prontera = mapLocalization.localizedMapName(forMapName: "prontera")
        XCTAssertEqual(prontera, "Prontera City, Capitol of Rune-Midgard")
    }
}
