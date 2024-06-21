//
//  ClientResourceBundle.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import CoreGraphics
import Foundation
import ROCore
import RODatabase
import ROFileFormats
import ROFileSystem
import ROResources

public class ClientResourceBundle {
    public static let shared = ClientResourceBundle()

    public let url: URL

    let grfs: [GRFReference]

    let cache = NSCache<NSString, CGImage>()

    public init() {
        url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        grfs = [
            GRFReference(url: url.appendingPathComponent("rdata.grf")),
            GRFReference(url: url.appendingPathComponent("data.grf")),
        ]
    }

    // MARK: - data

    public func rswFile(forMap map: Map) -> File? {
        let path = GRF.Path(string: "data\\\(map.name).rsw")
        let file = grfEntryFile(at: path)
        return file
    }

    // MARK: - data\palette

    public func headPaletteFile(forGender gender: Gender, hairID: Int, paletteID: Int) -> File? {
        let path = GRF.Path(string: "data\\palette\\머리\\머리\(hairID)_\(gender.resourceName)_\(paletteID).pal")
        let file = grfEntryFile(at: path)
        return file
    }

    // MARK: - data\sprite

    public func itemSpriteFile(forResourceName resourceName: String) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).spr")
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).act")
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    public func monsterSpriteFile(forResourceName resourceName: String) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).spr")
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).act")
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    public func bodySpriteFile(forGender gender: Gender, job: Job) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(gender.resourceName)\\\(job.resourceName)_\(gender.resourceName).spr")
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(gender.resourceName)\\\(job.resourceName)_\(gender.resourceName).act")
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    public func headSpriteFile(forGender gender: Gender, hairID: Int) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(string: "data\\sprite\\인간족\\머리통\\\(gender.resourceName)\\\(hairID)_\(gender.resourceName).spr")
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\인간족\\머리통\\\(gender.resourceName)\\\(hairID)_\(gender.resourceName).act")
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    public func skillSpriteFile(forResourceName resourceName: String) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).spr")
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).act")
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    // MARK: - data\texture

    public func itemIconImage(forItem item: Item) async -> CGImage? {
        guard let resourceName = await DatabaseResource.shared.identifiedItemResourceName(for: item.id) else {
            return nil
        }

        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\item\\\(resourceName).bmp")
        let image = await image(forBMPPath: path)
        return image
    }

    public func itemPreviewImage(forItem item: Item) async -> CGImage? {
        guard let resourceName = await DatabaseResource.shared.identifiedItemResourceName(for: item.id) else {
            return nil
        }

        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\collection\\\(resourceName).bmp")
        let image = await image(forBMPPath: path)
        return image
    }

    public func skillIconImage(forSkill skill: Skill) async -> CGImage? {
        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\item\\\(skill.aegisName).bmp")
        let image = await image(forBMPPath: path)
        return image
    }

    public func mapImage(forMap map: Map) async -> CGImage? {
        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\map\\\(map.name).bmp")
        let image = await image(forBMPPath: path)
        return image
    }

    // MARK: - Private

    private func image(forBMPPath path: GRF.Path) async -> CGImage? {
        if let image = cache.object(forKey: path.string as NSString) {
            return image
        }

        guard let file = grfEntryFile(at: path) else {
            return nil
        }

        guard let data = file.contents() else {
            return nil
        }

        let image = CGImageCreateWithData(data)?.removingMagentaPixels()

        if let image {
            cache.setObject(image, forKey: path.string as NSString)
        }

        return image
    }

    private func grfEntryFile(at path: GRF.Path) -> File? {
        for grf in grfs {
            if grf.entry(at: path) != nil {
                return .grfEntry(grf, path)
            }
        }
        return nil
    }
}
