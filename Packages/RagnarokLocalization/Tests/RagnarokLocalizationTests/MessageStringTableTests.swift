//
//  MessageStringTableTests.swift
//  RagnarokLocalizationTests
//
//  Created by Leon Li on 2024/6/14.
//

import XCTest
@testable import RagnarokLocalization

final class MessageStringTableTests: XCTestCase {
    func testChineseSimplified() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanSimplified)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "请问是否同意?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "苹果", 1)
        XCTAssertEqual(youGotApple, "取得 苹果 1 个")
    }

    func testChineseTraditional() async throws {
        let locale = Locale(languageCode: .chinese, script: .hanTraditional)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "請問是否同意？")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "蘋果", 1)
        XCTAssertEqual(youGotApple, "取得 蘋果 1 個")
    }

    func testEnglish() async throws {
        let locale = Locale(languageCode: .english)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "Do you agree?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Apple", 1)
        XCTAssertEqual(youGotApple, "You got Apple (1).")
    }

    func testFrench() async throws {
        let locale = Locale(languageCode: .french)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "Acceptez-vous? ")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Apple", 1)
        XCTAssertEqual(youGotApple, "Vous obtenez Apple (1). ")
    }

    func testGerman() async throws {
        let locale = Locale(languageCode: .german)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "Zustimmen?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Apple", 1)
        XCTAssertEqual(youGotApple, "Apple (1)erhalten.")
    }

    func testIndonesian() async throws {
        let locale = Locale(languageCode: .indonesian)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "Apa kamu ingin bermain ?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Apple", 1)
        XCTAssertEqual(youGotApple, "Apple yang kamu dapat adalah 1  ")
    }

    func testItalian() async throws {
        let locale = Locale(languageCode: .italian)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "Do you agree?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Apple", 1)
        XCTAssertEqual(youGotApple, "You got Apple (1).")
    }

    func testJapanese() async throws {
        let locale = Locale(languageCode: .japanese)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "同意しますか？")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "リンゴ", 1)
        XCTAssertEqual(youGotApple, "リンゴ 1 個獲得")
    }

    func testKorean() async throws {
        let locale = Locale(languageCode: .korean)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "동의 하십니까?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "사과", 1)
        XCTAssertEqual(youGotApple, "사과 1 개 획득")
    }

    func testPortuguese() async throws {
        let locale = Locale(languageCode: .portuguese, languageRegion: .brazil)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "Você concorda?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Maçã", 1)
        XCTAssertEqual(youGotApple, "Você obteve Maçã (1).")
    }

    func testRussian() async throws {
        let locale = Locale(languageCode: .russian)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "Вы согласны?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Яблоко", 1)
        XCTAssertEqual(youGotApple, "Вы получаете Яблоко (1).")
    }

    func testSpanish() async throws {
        let locale = Locale(languageCode: .spanish)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "¿Estás de acuerdo?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Apple", 1)
        XCTAssertEqual(youGotApple, "Tienes Apple (1).")
    }

    func testThai() async throws {
        let locale = Locale(languageCode: .thai)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "คุณตกลงหรือไม่?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Apple", 1)
        XCTAssertEqual(youGotApple, "คุณได้รับ Apple 1 ea")
    }

    func testTurkish() async throws {
        let locale = Locale(languageCode: .turkish)
        let messageStringTable = MessageStringTable(locale: locale)

        let doYouAgree = messageStringTable.localizedMessageString(forID: 0)
        XCTAssertEqual(doYouAgree, "Do you agree?")

        let youGotApple = messageStringTable.localizedMessageString(forID: 153, arguments: "Apple", 1)
        XCTAssertEqual(youGotApple, "You got Apple (1).")
    }
}
