//
//  SkillInfoTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/5/29.
//

import XCTest
@testable import ROResources

final class SkillInfoTableTests: XCTestCase {
    let resourceManager = ResourceManager(
        locale: .current,
        localURL: Bundle.main.resourceURL!,
        remoteURL: URL(string: "http://127.0.0.1:8080/client")
    )

    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "治愈术")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "治癒術")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testFrench() async throws {
        let locale = Locale(languageCode: .french)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testGerman() async throws {
        let locale = Locale(languageCode: .german)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testIndonesian() async throws {
        let locale = Locale(languageCode: .indonesian)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testItalian() async throws {
        let locale = Locale(languageCode: .italian)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testJapanese() async throws {
        let locale = Locale(languageCode: .japanese)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "ヒール")
    }

    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "힐")
    }

    func testPortuguese() async throws {
        let locale = Locale(languageCode: .portuguese, languageRegion: .brazil)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Curar")
    }

    func testRussian() async throws {
        let locale = Locale(languageCode: .russian)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Лечение")
    }

    func testSpanish() async throws {
        let locale = Locale(languageCode: .spanish)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testThai() async throws {
        let locale = Locale(languageCode: .thai)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }

    func testTurkish() async throws {
        let locale = Locale(languageCode: .turkish)
        let scriptContext = await resourceManager.scriptContext(for: locale)
        let heal = scriptContext.localizedSkillName(forSkillID: 28)
        XCTAssertEqual(heal, "Heal")
    }
}
