//
//  MessageStringTableTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2024/6/14.
//

import XCTest
@testable import ROLocalizations

final class MessageStringTableTests: XCTestCase {
    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "请问是否同意?")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "請問是否同意？")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Do you agree?")
    }

    func testFrench() async throws {
        let locale = Locale(languageCode: .french)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Acceptez-vous? ")
    }

    func testGerman() async throws {
        let locale = Locale(languageCode: .german)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Zustimmen?")
    }

    func testIndonesian() async throws {
        let locale = Locale(languageCode: .indonesian)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Apa kamu ingin bermain ?")
    }

    func testItalian() async throws {
        let locale = Locale(languageCode: .italian)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Do you agree?")
    }

    func testJapanese() async throws {
        let locale = Locale(languageCode: .japanese)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "同意しますか？")
    }

    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "동의 하십니까?")
    }

    func testPortuguese() async throws {
        let locale = Locale(languageCode: .portuguese, languageRegion: .brazil)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Você concorda?")
    }

    func testRussian() async throws {
        let locale = Locale(languageCode: .russian)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Вы согласны?")
    }

    func testSpanish() async throws {
        let locale = Locale(languageCode: .spanish)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "¿Estás de acuerdo?")
    }

    func testThai() async throws {
        let locale = Locale(languageCode: .thai)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "คุณตกลงหรือไม่?")
    }

    func testTurkish() async throws {
        let locale = Locale(languageCode: .turkish)
        let messageLocalization = MessageStringTable(locale: locale)
        let doYouAgree = messageLocalization.localizedMessageString(at: 0)
        XCTAssertEqual(doYouAgree, "Do you agree?")
    }
}