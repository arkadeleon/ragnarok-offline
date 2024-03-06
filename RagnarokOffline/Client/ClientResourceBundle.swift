//
//  ClientResourceBundle.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Foundation
import rAthenaDatabase

class ClientResourceBundle {
    static let shared = ClientResourceBundle()

    let url: URL

    let grf: GRFWrapper

    init() {
        url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        grf = GRFWrapper(url: url.appendingPathComponent("data.grf"))
    }

    // MARK: - data

    func mapNameTableFile() -> File {
        let path = GRF.Path(string: "data\\mapnametable.txt")
        let file = File.grfEntry(grf, path)
        return file
    }

    // MARK: - data\palette

    func headPaletteFile(forGender gender: Gender, hairID: Int, paletteID: Int) -> File {
        let palPath = GRF.Path(string: "data\\palette\\머리\\머리\(hairID)_\(gender.resourceName)_\(paletteID).pal")
        let palFile = File.grfEntry(grf, palPath)
        return palFile
    }

    // MARK: - data\sprite

    func itemSpriteFile(forResourceName resourceName: String) -> (spr: File, act: File) {
        let sprPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).spr")
        let sprFile = File.grfEntry(grf, sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).act")
        let actFile = File.grfEntry(grf, actPath)

        return (spr: sprFile, act: actFile)
    }

    func monsterSpriteFile(forResourceName resourceName: String) -> (spr: File, act: File) {
        let sprPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).spr")
        let sprFile = File.grfEntry(grf, sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).act")
        let actFile = File.grfEntry(grf, actPath)

        return (spr: sprFile, act: actFile)
    }

    func bodySpriteFile(forGender gender: Gender, job: Job) -> (spr: File, act: File) {
        let sprPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(gender.resourceName)\\\(job.resourceName)_\(gender.resourceName).spr")
        let sprFile = File.grfEntry(grf, sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(gender.resourceName)\\\(job.resourceName)_\(gender.resourceName).act")
        let actFile = File.grfEntry(grf, actPath)

        return (spr: sprFile, act: actFile)
    }

    func headSpriteFile(forGender gender: Gender, hairID: Int) -> (spr: File, act: File) {
        let sprPath = GRF.Path(string: "data\\sprite\\인간족\\머리통\\\(gender.resourceName)\\\(hairID)_\(gender.resourceName).spr")
        let sprFile = File.grfEntry(grf, sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\인간족\\머리통\\\(gender.resourceName)\\\(hairID)_\(gender.resourceName).act")
        let actFile = File.grfEntry(grf, actPath)

        return (spr: sprFile, act: actFile)
    }

    func skillSpriteFile(forResourceName resourceName: String) -> (spr: File, act: File) {
        let sprPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).spr")
        let sprFile = File.grfEntry(grf, sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).act")
        let actFile = File.grfEntry(grf, actPath)

        return (spr: sprFile, act: actFile)
    }

    // MARK: - data\texture

    func itemIconFile(forResourceName resourceName: String) -> File {
        let bmpPath = GRF.Path(string: "data\\texture\\유저인터페이스\\item\\\(resourceName).bmp")
        let bmpFile = File.grfEntry(grf, bmpPath)
        return bmpFile
    }

    func itemPreviewFile(forResourceName resourceName: String) -> File {
        let bmpPath = GRF.Path(string: "data\\texture\\유저인터페이스\\collection\\\(resourceName).bmp")
        let bmpFile = File.grfEntry(grf, bmpPath)
        return bmpFile
    }

    func skillIconFile(forResourceName resourceName: String) -> File {
        let bmpPath = GRF.Path(string: "data\\texture\\유저인터페이스\\item\\\(resourceName).bmp")
        let bmpFile = File.grfEntry(grf, bmpPath)
        return bmpFile
    }

    func mapPreviewFile(forResourceName resourceName: String) -> File {
        let bmpPath = GRF.Path(string: "data\\texture\\유저인터페이스\\map\\\(resourceName).bmp")
        let bmpFile = File.grfEntry(grf, bmpPath)
        return bmpFile
    }
}
