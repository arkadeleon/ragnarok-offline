//
//  GRFTests.swift
//  ROFileFormatsTests
//
//  Created by Leon Li on 2020/5/4.
//

import XCTest
import ROStream
@testable import ROFileFormats

final class GRFTests: XCTestCase {
    func testGRF() throws {
        let url = Bundle.module.resourceURL!.appending(path: "test.grf")
        let grf = try GRF(url: url)
        XCTAssertEqual(grf.table.entries.count, 9)
        XCTAssertEqual(grf.table.entries[0].path.string, "data\\0_Tex1.bmp")
        XCTAssertEqual(grf.table.entries[1].path.string, "data\\11001.txt")
        XCTAssertEqual(grf.table.entries[2].path.string, "data\\balls.wav")
        XCTAssertEqual(grf.table.entries[3].path.string, "data\\idnum2itemdesctable.txt")
        XCTAssertEqual(grf.table.entries[4].path.string, "data\\idnum2itemdisplaynametable.txt")
        XCTAssertEqual(grf.table.entries[5].path.string, "data\\loading00.jpg")
        XCTAssertEqual(grf.table.entries[6].path.string, "data\\monstertalktable.xml")
        XCTAssertEqual(grf.table.entries[7].path.string, "data\\resnametable.txt")
        XCTAssertEqual(grf.table.entries[8].path.string, "data\\t2_배경1-1.bmp")

        let files = [
            Bundle.module.resourceURL!.appending(path: "data/0_Tex1.bmp"),
            Bundle.module.resourceURL!.appending(path: "data/11001.txt"),
            Bundle.module.resourceURL!.appending(path: "data/balls.wav"),
            Bundle.module.resourceURL!.appending(path: "data/idnum2itemdesctable.txt"),
            Bundle.module.resourceURL!.appending(path: "data/idnum2itemdisplaynametable.txt"),
            Bundle.module.resourceURL!.appending(path: "data/loading00.jpg"),
            Bundle.module.resourceURL!.appending(path: "data/monstertalktable.xml"),
            Bundle.module.resourceURL!.appending(path: "data/resnametable.txt"),
            Bundle.module.resourceURL!.appending(path: "data/t2_배경1-1.bmp")
        ]

        let stream = try FileStream(url: url)
        let reader = BinaryReader(stream: stream)

        for (i, entry) in grf.table.entries.enumerated() {
            try XCTAssertEqual(entry.data(from: reader), Data(contentsOf: files[i]))
        }

        stream.close()
    }

    static var allTests = [
        ("testGRF", testGRF),
    ]
}
