//
//  GameResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import CoreGraphics
import Foundation
import ROCore
import ROFileFormats
import ROGenerated
import ROResources

enum GameResourceError: Error {
    case resourceNotFound
}

@MainActor
final public class GameResourceManager {
    public static let `default` = GameResourceManager()

    public let baseURL: URL

    let grfs: [GRFReference]

    private let cache = NSCache<NSString, CGImage>()

    init() {
        baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        grfs = [
            GRFReference(url: baseURL.appending(path: "data.grf")),
        ]
    }

    public func monsterImage(_ monsterID: Int) async throws -> CGImage? {
        let (spr, act) = try await sprite(forMonsterID: monsterID)

        let imagesBySpriteType = spr.imagesBySpriteType()
        let animatedImage = act.actions.first?.animatedImage(using: imagesBySpriteType)
        let image = animatedImage?.images.first
        return image
    }

    public func jobImage(forJobID jobID: JobID, sex: Sex) async throws -> CGImage? {
        let (spr, act) = try await sprite(forJobID: jobID, sex: sex)

        let imagesBySpriteType = spr.imagesBySpriteType()
        let animatedImage = act.actions.first?.animatedImage(using: imagesBySpriteType)
        let image = animatedImage?.images.first
        return image
    }

    // MARK: - BGM

    public func bgmURL(forMapName mapName: String) async throws -> URL {
        guard let bgm = await mapMP3NameTable.mapMP3Name(forMapName: mapName) else {
            throw GameResourceError.resourceNotFound
        }

        let url = baseURL.appending(path: "BGM/\(bgm)")
        return url
    }

    // MARK: - data

    public func gat(forMapName mapName: String) async throws -> GAT {
        let path = GRF.Path(components: ["data", "\(mapName).gat"])
        let data = try contentsOfEntry(at: path)
        let gat = try GAT(data: data)
        return gat
    }

    public func gnd(forMapName mapName: String) async throws -> GND {
        let path = GRF.Path(components: ["data", "\(mapName).gnd"])
        let data = try contentsOfEntry(at: path)
        let gnd = try GND(data: data)
        return gnd
    }

    public func rsw(forMapName mapName: String) async throws -> RSW {
        let path = GRF.Path(components: ["data", "\(mapName).rsw"])
        let data = try contentsOfEntry(at: path)
        let rsw = try RSW(data: data)
        return rsw
    }

    // MARK: - data\model

    public func rsm(forModelName modelName: String) async throws -> RSM {
        let path = GRF.Path(components: ["data", "model", modelName])
        let data = try contentsOfEntry(at: path)
        let rsm = try RSM(data: data)
        return rsm
    }

    // MARK: - data\palette

    public func palette(forHairStyle hairStyle: Int, hairColor: Int, sex: Sex) async throws -> PAL {
        let path = GRF.Path(components: ["data", "palette", "머리", "머리", "\(hairStyle)_\(sex.resourceName)_\(hairColor).pal"])
        let data = try contentsOfEntry(at: path)
        let pal = try PAL(data: data)
        return pal
    }

    // MARK: - data\sprite

    public func sprite(forItemID itemID: Int) async throws -> (spr: SPR, act: ACT) {
        guard let resourceName = await itemInfoTable.identifiedItemResourceName(forItemID: itemID) else {
            throw GameResourceError.resourceNotFound
        }

        let sprPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "아이템", "\(resourceName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr, act)
    }

    public func sprite(forMonsterID monsterID: Int) async throws -> (spr: SPR, act: ACT) {
        guard let resourceName = await jobNameTable.jobName(forJobID: monsterID) else {
            throw GameResourceError.resourceNotFound
        }

        let sprPath = GRF.Path(components: ["data", "sprite", "몬스터", "\(resourceName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "몬스터", "\(resourceName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr, act)
    }

    public func sprite(forJobID jobID: JobID, sex: Sex) async throws -> (spr: SPR, act: ACT) {
        let sprPath = GRF.Path(components: ["data", "sprite", "인간족", "몸통", "\(sex.resourceName)", "\(jobID.resourceName)_\(sex.resourceName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "인간족", "몸통", "\(sex.resourceName)", "\(jobID.resourceName)_\(sex.resourceName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr, act)
    }

    public func sprite(forHairStyle hairStyle: Int, sex: Sex) async throws -> (spr: SPR, act: ACT) {
        let sprPath = GRF.Path(components: ["data", "sprite", "인간족", "머리통", "\(sex.resourceName)", "\(hairStyle)_\(sex.resourceName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "인간족", "머리통", "\(sex.resourceName)", "\(hairStyle)_\(sex.resourceName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr, act)
    }

    public func sprite(forSkillName skillName: String) async throws -> (spr: SPR, act: ACT) {
        let sprPath = GRF.Path(components: ["data", "sprite", "아이템", "\(skillName).spr"])
        let sprData = try contentsOfEntry(at: sprPath)
        let spr = try SPR(data: sprData)

        let actPath = GRF.Path(components: ["data", "sprite", "아이템", "\(skillName).act"])
        let actData = try contentsOfEntry(at: actPath)
        let act = try ACT(data: actData)

        return (spr, act)
    }

    // MARK: - data\texture

    public func image(forTextureNamed textureName: String) async throws -> CGImage? {
        let path = GRF.Path(components: ["data", "texture", textureName])
        let data = try contentsOfEntry(at: path)
        let image = CGImageCreateWithData(data)
        return image
    }

    public func itemIconImage(forItemID itemID: Int) async throws -> CGImage? {
        guard let resourceName = await itemInfoTable.identifiedItemResourceName(forItemID: itemID) else {
            throw GameResourceError.resourceNotFound
        }

        let path = GRF.Path(components: ["data", "texture", "유저인터페이스", "item", "\(resourceName).bmp"])
        let image = await image(forBMPPath: path)
        return image
    }

    public func itemPreviewImage(forItemID itemID: Int) async throws -> CGImage? {
        guard let resourceName = await itemInfoTable.identifiedItemResourceName(forItemID: itemID) else {
            throw GameResourceError.resourceNotFound
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

    public func statusIconImage(forStatusID statusID: Int) async throws -> CGImage? {
        guard let iconName = await statusInfoTable.iconName(forStatusID: statusID) else {
            throw GameResourceError.resourceNotFound
        }

        let path = GRF.Path(components: ["data", "texture", "effect", iconName])
        let data = try contentsOfEntry(at: path)
        let image = CGImageCreateWithData(data)
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
        throw GameResourceError.resourceNotFound
    }
}
