//
//  ClientResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import CoreGraphics
import Foundation
import ROCore
import ROFileFormats
import ROFileSystem
import ROGenerated
import ROLocalizations

public actor ClientResourceManager {
    public static let `default` = ClientResourceManager()

    nonisolated public let baseURL: URL

    let grfs: [GRFReference]

    private let cache = NSCache<NSString, CGImage>()

    public init() {
        baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        grfs = [
            GRFReference(url: baseURL.appending(path: "rdata.grf")),
            GRFReference(url: baseURL.appending(path: "data.grf")),
        ]
    }

    public func monsterImage(_ monsterID: Int) async -> CGImage? {
        guard let resourceName = MonsterInfoTable.shared.monsterResourceName(forMonsterID: monsterID) else {
            return nil
        }

        let (sprFile, actFile) = monsterSpriteFile(forResourceName: resourceName)
        guard let sprFile, let sprData = sprFile.contents(), let actFile, let actData = actFile.contents() else {
            return nil
        }

        do {
            let spr = try SPR(data: sprData)
            let act = try ACT(data: actData)

            let sprites = spr.sprites.enumerated()
            let spritesByType = Dictionary(grouping: sprites, by: { $0.element.type })
            let imagesForSpritesByType = spritesByType.mapValues { sprites in
                sprites.map { sprite in
                    spr.image(forSpriteAt: sprite.offset)
                }
            }

            let animatedImage = act.animatedImage(forActionAt: 0, imagesForSpritesByType: imagesForSpritesByType)
            let image = animatedImage.images.first
            return image
        } catch {
            return nil
        }
    }

    public func jobImage(sex: Sex, jobID: JobID) async -> CGImage? {
        let (sprFile, actFile) = bodySpriteFile(sex: sex, jobID: jobID)

        guard let sprFile, let sprData = sprFile.contents(), let actFile, let actData = actFile.contents() else {
            return nil
        }

        do {
            let spr = try SPR(data: sprData)
            let act = try ACT(data: actData)

            let sprites = spr.sprites.enumerated()
            let spritesByType = Dictionary(grouping: sprites, by: { $0.element.type })
            let imagesForSpritesByType = spritesByType.mapValues { sprites in
                sprites.map { sprite in
                    spr.image(forSpriteAt: sprite.offset)
                }
            }

            let animatedImage = act.animatedImage(forActionAt: 0, imagesForSpritesByType: imagesForSpritesByType)
            let image = animatedImage.images.first
            return image
        } catch {
            return nil
        }
    }

    // MARK: - data

    public func rswFile(forMapName mapName: String) -> File? {
        let path = GRF.Path(components: ["data", "\(mapName).rsw"])
        let file = grfEntryFile(at: path)
        return file
    }

    // MARK: - data\palette

    public func headPaletteFile(sex: Sex, hairID: Int, paletteID: Int) -> File? {
        let path = GRF.Path(components: ["data", "palette", "머리", "머리", "\(hairID)_\(sex.resourceName)_\(paletteID).pal"])
        let file = grfEntryFile(at: path)
        return file
    }

    // MARK: - data\sprite

    public func itemSpriteFile(forResourceName resourceName: String) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).spr"])
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).act"])
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    public func monsterSpriteFile(forResourceName resourceName: String) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(components: ["data", "sprite", "몬스터", "\(resourceName).spr"])
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(components: ["data", "sprite", "몬스터", "\(resourceName).act"])
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    public func bodySpriteFile(sex: Sex, jobID: JobID) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(components: ["data", "sprite", "인간족", "몸통", "\(sex.resourceName)", "\(jobID.resourceName)_\(sex.resourceName).spr"])
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(components: ["data", "sprite", "인간족", "몸통", "\(sex.resourceName)", "\(jobID.resourceName)_\(sex.resourceName).act"])
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    public func headSpriteFile(sex: Sex, hairID: Int) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(components: ["data", "sprite", "인간족", "머리통", "\(sex.resourceName)", "\(hairID)_\(sex.resourceName).spr"])
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(components: ["data", "sprite", "인간족", "머리통", "\(sex.resourceName)", "\(hairID)_\(sex.resourceName).act"])
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    public func skillSpriteFile(forResourceName resourceName: String) -> (spr: File?, act: File?) {
        let sprPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).spr"])
        let sprFile = grfEntryFile(at: sprPath)

        let actPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).act"])
        let actFile = grfEntryFile(at: actPath)

        return (spr: sprFile, act: actFile)
    }

    // MARK: - data\texture

    public func itemIconImage(forItemID itemID: Int) async -> CGImage? {
        guard let resourceName = ItemInfoTable.shared.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        let path = GRF.Path(components: ["data", "texture", "유저인터페이스", "item", "\(resourceName).bmp"])
        let image = await image(forBMPPath: path)
        return image
    }

    public func itemPreviewImage(forItemID itemID: Int) async -> CGImage? {
        guard let resourceName = ItemInfoTable.shared.identifiedItemResourceName(forItemID: itemID) else {
            return nil
        }

        let path = GRF.Path(components: ["data", "texture", "유저인터페이스", "collection", "\(resourceName).bmp"])
        let image = await image(forBMPPath: path)
        return image
    }

    public func skillIconImage(forSkillAegisName skillAegisName: String) async -> CGImage? {
        let path = GRF.Path(components: ["data", "texture", "유저인터페이스", "item", "\(skillAegisName).bmp"])
        let image = await image(forBMPPath: path)
        return image
    }

    public func mapImage(forMapName mapName: String) async -> CGImage? {
        let path = GRF.Path(components: ["data", "texture", "유저인터페이스", "map", "\(mapName).bmp"])
        let image = await image(forBMPPath: path)
        return image
    }

    // MARK: - General

    public func image(forBMPPath path: GRF.Path) async -> CGImage? {
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

    public func grfEntryFile(at path: GRF.Path) -> File? {
        for grf in grfs {
            if grf.entry(at: path) != nil {
                return .grfEntry(grf, path)
            }
        }
        return nil
    }
}
