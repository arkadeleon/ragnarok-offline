//
//  ClientResourceBundle.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import CoreGraphics
import Foundation
import rAthenaDatabase
import RagnarokOfflineFileFormats
import RagnarokOfflineGraphics

class ClientResourceBundle {
    static let shared = ClientResourceBundle()

    let url: URL

    let grf: GRFWrapper

    private let cache = NSCache<NSString, CGImage>()

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

    func identifiedItemDisplayNameTable() -> File {
        let path = GRF.Path(string: "data\\idnum2itemdisplaynametable.txt")
        let file = File.grfEntry(grf, path)
        return file
    }

    func identifiedItemResourceNameTable() -> File {
        let path = GRF.Path(string: "data\\idnum2itemresnametable.txt")
        let file = File.grfEntry(grf, path)
        return file
    }

    func identifiedItemDescriptionTable() -> File {
        let path = GRF.Path(string: "data\\idnum2itemdesctable.txt")
        let file = File.grfEntry(grf, path)
        return file
    }

    func rswFile(forMap map: Map) -> File {
        let path = GRF.Path(string: "data\\\(map.name).rsw")
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

    func itemIconImage(forItem item: Item) async -> CGImage? {
        guard let resourceName = ClientDatabase.shared.identifiedItemResourceName(item.id) else {
            return nil
        }

        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\item\\\(resourceName).bmp")
        let image = await image(forBMPPath: path)
        return image
    }

    func itemPreviewImage(forItem item: Item) async -> CGImage? {
        guard let resourceName = ClientDatabase.shared.identifiedItemResourceName(item.id) else {
            return nil
        }

        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\collection\\\(resourceName).bmp")
        let image = await image(forBMPPath: path)
        return image
    }

    func skillIconImage(forSkill skill: Skill) async -> CGImage? {
        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\item\\\(skill.aegisName).bmp")
        let image = await image(forBMPPath: path)
        return image
    }

    func mapImage(forMap map: Map) async -> CGImage? {
        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\map\\\(map.name).bmp")
        let image = await image(forBMPPath: path)
        return image
    }

    // MARK: - Private

    private func image(forBMPPath path: GRF.Path) async -> CGImage? {
        if let image = cache.object(forKey: path.string as NSString) {
            return image
        }

        let file = File.grfEntry(grf, path)

        guard let data = file.contents() else {
            return nil
        }

        let image = CGImageCreateWithData(data)?.removingMagentaPixels()

        if let image {
            cache.setObject(image, forKey: path.string as NSString)
        }

        return image
    }
}
