//
//  GRFDocumentTests.swift
//  RagnarokOfflineTests
//
//  Created by Leon Li on 2020/5/4.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import XCTest
@testable import RagnarokOffline

class GRFDocumentTests: XCTestCase {

    func testGRFDocument() throws {
        let url = Bundle(for: GRFDocumentTests.self).url(forResource: "test", withExtension: "grf")!
        let grf = try GRFDocument(url: url)
        XCTAssert(grf.entries.count == 9)
        XCTAssert(grf.entries[0].filename == "data\\0_Tex1.bmp")
        XCTAssert(grf.entries[1].filename == "data\\11001.txt")
        XCTAssert(grf.entries[2].filename == "data\\balls.wav")
        XCTAssert(grf.entries[3].filename == "data\\idnum2itemdesctable.txt")
        XCTAssert(grf.entries[4].filename == "data\\idnum2itemdisplaynametable.txt")
        XCTAssert(grf.entries[5].filename == "data\\loading00.jpg")
        XCTAssert(grf.entries[6].filename == "data\\monstertalktable.xml")
        XCTAssert(grf.entries[7].filename == "data\\resnametable.txt")
        XCTAssert(grf.entries[8].filename == "data\\t2_¹è°æ1-1.bmp")

        let files = [
            Bundle(for: GRFDocumentTests.self).url(forResource: "0_Tex1", withExtension: "bmp")!,
            Bundle(for: GRFDocumentTests.self).url(forResource: "11001", withExtension: "txt")!,
            Bundle(for: GRFDocumentTests.self).url(forResource: "balls", withExtension: "wav")!,
            Bundle(for: GRFDocumentTests.self).url(forResource: "idnum2itemdesctable", withExtension: "txt")!,
            Bundle(for: GRFDocumentTests.self).url(forResource: "idnum2itemdisplaynametable", withExtension: "txt")!,
            Bundle(for: GRFDocumentTests.self).url(forResource: "loading00", withExtension: "jpg")!,
            Bundle(for: GRFDocumentTests.self).url(forResource: "monstertalktable", withExtension: "xml")!,
            Bundle(for: GRFDocumentTests.self).url(forResource: "resnametable", withExtension: "txt")!,
            Bundle(for: GRFDocumentTests.self).url(forResource: "t2_배경1-1", withExtension: "bmp")!
        ]

        for (i, entry) in grf.entries.enumerated() {
            try XCTAssert(grf.contents(of: entry) == Data(contentsOf: files[i]))
        }
    }
}
