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
import ROGenerated
import ROLocalizations

enum ClientResourceError: Error {
    case resourceNotFound
}

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

    public func monsterImage(_ monsterID: Int) async throws -> CGImage? {
        guard let resourceName = MonsterInfoTable.shared.monsterResourceName(forMonsterID: monsterID) else {
            return nil
        }

        let (spr, act) = try monsterSpriteFile(forResourceName: resourceName)

        let imagesBySpriteType = spr.imagesBySpriteType()
        let animatedImage = act.actions.first?.animatedImage(using: imagesBySpriteType)
        let image = animatedImage?.images.first
        return image
    }

    public func jobImage(sex: Sex, jobID: JobID) async throws -> CGImage? {
        let (spr, act) = try bodySpriteFile(sex: sex, jobID: jobID)

        let imagesBySpriteType = spr.imagesBySpriteType()
        let animatedImage = act.actions.first?.animatedImage(using: imagesBySpriteType)
        let image = animatedImage?.images.first
        return image
    }

    // MARK: - data

    public func gatFile(forMapName mapName: String) throws -> GAT {
        let path = GRF.Path(components: ["data", "\(mapName).gat"])
        let data = try contentsOfEntry(at: path)
        let gat = try GAT(data: data)
        return gat
    }

    public func gndFile(forMapName mapName: String) throws -> GND {
        let path = GRF.Path(components: ["data", "\(mapName).gnd"])
        let data = try contentsOfEntry(at: path)
        let gnd = try GND(data: data)
        return gnd
    }

    public func rswFile(forMapName mapName: String) throws -> RSW {
        let path = GRF.Path(components: ["data", "\(mapName).rsw"])
        let data = try contentsOfEntry(at: path)
        let rsw = try RSW(data: data)
        return rsw
    }

    // MARK: - data\palette

    public func headPaletteFile(sex: Sex, hairID: Int, paletteID: Int) throws -> PAL {
        let path = GRF.Path(components: ["data", "palette", "머리", "머리", "\(hairID)_\(sex.resourceName)_\(paletteID).pal"])
        let data = try contentsOfEntry(at: path)
        let pal = try PAL(data: data)
        return pal
    }

    // MARK: - data\sprite

    public func itemSpriteFile(forResourceName resourceName: String) throws -> (spr: SPR, act: ACT) {
        let sprPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr: spr, act: act)
    }

    public func monsterSpriteFile(forResourceName resourceName: String) throws -> (spr: SPR, act: ACT) {
        let sprPath = GRF.Path(components: ["data", "sprite", "몬스터", "\(resourceName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "몬스터", "\(resourceName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr: spr, act: act)
    }

    public func bodySpriteFile(sex: Sex, jobID: JobID) throws -> (spr: SPR, act: ACT) {
        let sprPath = GRF.Path(components: ["data", "sprite", "인간족", "몸통", "\(sex.resourceName)", "\(jobID.resourceName)_\(sex.resourceName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "인간족", "몸통", "\(sex.resourceName)", "\(jobID.resourceName)_\(sex.resourceName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr: spr, act: act)
    }

    public func headSpriteFile(sex: Sex, hairID: Int) throws -> (spr: SPR, act: ACT) {
        let sprPath = GRF.Path(components: ["data", "sprite", "인간족", "머리통", "\(sex.resourceName)", "\(hairID)_\(sex.resourceName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "인간족", "머리통", "\(sex.resourceName)", "\(hairID)_\(sex.resourceName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr: spr, act: act)
    }

    public func skillSpriteFile(forResourceName resourceName: String) throws -> (spr: SPR, act: ACT) {
        let sprPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr: spr, act: act)
    }

    // MARK: - data\texture

    public func image(forTextureNamed textureName: String) throws -> CGImage? {
        let path = GRF.Path(components: ["data", "texture", textureName])
        let data = try contentsOfEntry(at: path)
        let image = CGImageCreateWithData(data)
        return image
    }

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

        guard let data = try? contentsOfEntry(at: path) else {
            return nil
        }

        let image = CGImageCreateWithData(data)?.removingMagentaPixels()

        if let image {
            cache.setObject(image, forKey: path.string as NSString)
        }

        return image
    }

    public func contentsOfEntry(at path: GRF.Path) throws -> Data {
        for grf in grfs {
            if grf.entry(at: path) != nil {
                return try grf.contentsOfEntry(at: path)
            }
        }
        throw ClientResourceError.resourceNotFound
    }
}
