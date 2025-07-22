//
//  MessageStringTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/6/14.
//

import XCTest
@testable import ROResources

final class MessageStringTableTests: XCTestCase {
    let resourceManager = ResourceManager(
        localURL: Bundle.main.resourceURL!,
        remoteURL: URL(string: "http://127.0.0.1:8080/client")
    )

    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 1)
        XCTAssertEqual(doYouAgree, "请问是否同意?")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "請問是否同意？")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Do you agree?")
    }

    func testFrench() async throws {
        let locale = Locale(languageCode: .french)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Acceptez-vous? ")
    }

    func testGerman() async throws {
        let locale = Locale(languageCode: .german)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Zustimmen?")
    }

    func testIndonesian() async throws {
        let locale = Locale(languageCode: .indonesian)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Apa kamu ingin bermain ?")
    }

    func testItalian() async throws {
        let locale = Locale(languageCode: .italian)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Do you agree?")
    }

    func testJapanese() async throws {
        let locale = Locale(languageCode: .japanese)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "同意しますか？")
    }

    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "동의 하십니까?")
    }

    func testPortuguese() async throws {
        let locale = Locale(languageCode: .portuguese, languageRegion: .brazil)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Você concorda?")
    }

    func testRussian() async throws {
        let locale = Locale(languageCode: .russian)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Вы согласны?")
    }

    func testSpanish() async throws {
        let locale = Locale(languageCode: .spanish)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "¿Estás de acuerdo?")
    }

    func testThai() async throws {
        let locale = Locale(languageCode: .thai)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "คุณตกลงหรือไม่?")
    }

    func testTurkish() async throws {
        let locale = Locale(languageCode: .turkish)
        let messageStringTable = await resourceManager.messageStringTable(for: locale)
        let doYouAgree = messageStringTable.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Do you agree?")
    }
}
