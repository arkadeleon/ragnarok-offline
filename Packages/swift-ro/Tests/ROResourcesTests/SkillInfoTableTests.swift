//
//  SkillInfoTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/29.
//

import XCTest
@testable import ROResources

final class SkillInfoTableTests: XCTestCase {
    let localURL = Bundle.module.resourceURL!

    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "治愈术")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "治癒術")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testFrench() async throws {
        let locale = Locale(languageCode: .french)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testGerman() async throws {
        let locale = Locale(languageCode: .german)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testIndonesian() async throws {
        let locale = Locale(languageCode: .indonesian)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testItalian() async throws {
        let locale = Locale(languageCode: .italian)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testJapanese() async throws {
        let locale = Locale(languageCode: .japanese)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "ヒール")
    }

    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "힐")
    }

    func testPortuguese() async throws {
        let locale = Locale(languageCode: .portuguese, languageRegion: .brazil)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Curar")
    }

    func testRussian() async throws {
        let locale = Locale(languageCode: .russian)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Лечение")
    }

    func testSpanish() async throws {
        let locale = Locale(languageCode: .spanish)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testThai() async throws {
        let locale = Locale(languageCode: .thai)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testTurkish() async throws {
        let locale = Locale(languageCode: .turkish)
        let resourceManager = ResourceManager(locale: locale, localURL: localURL, remoteURL: nil)
        let scriptManager = await resourceManager.scriptManager()
        let heal = scriptManager.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }
}
