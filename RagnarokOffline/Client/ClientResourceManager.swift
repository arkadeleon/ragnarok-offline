//
//  ClientResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaCommon
import UIKit

class ClientResourceManager {
    static let shared = ClientResourceManager()

    func itemIconImage(_ itemID: Int) async -> UIImage? {
        guard let resourceName = ClientScriptManager.shared.itemResourceName(itemID) else {
            return nil
        }

        let path = GRF.Path(string: "data\\sprite\\아이템\\\(resourceName).spr")

        do {
            let sprData = try ClientBundle.shared.grf.contentsOfEntry(at: path)
            let spr = try SPR(data: sprData)
            guard let image = spr.image(forSpriteAt: 0) else {
                return nil
            }
            let uiImage = UIImage(cgImage: image.image)
            return uiImage
        } catch {
            return nil
        }
    }

    func itemPreviewImage(_ itemID: Int) async -> UIImage? {
        guard let resourceName = ClientScriptManager.shared.itemResourceName(itemID) else {
            return nil
        }

        let path = GRF.Path(string: "data\\texture\\유저인터페이스\\collection\\\(resourceName).bmp")

        do {
            let bmpData = try ClientBundle.shared.grf.contentsOfEntry(at: path)
            let image = UIImage(data: bmpData)
            return image
        } catch {
            return nil
        }
    }

    func monsterImage(_ monsterID: Int) async -> UIImage? {
        guard let resourceName = ClientScriptManager.shared.monsterResourceName(monsterID) else {
            return nil
        }

        let path = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).spr")

        print("Load: " + path.string)

        do {
            let sprData = try ClientBundle.shared.grf.contentsOfEntry(at: path)
            let spr = try SPR(data: sprData)
            guard let image = spr.image(forSpriteAt: 0) else {
                return nil
            }
            let uiImage = UIImage(cgImage: image.image)
            return uiImage
        } catch {
            return nil
        }
    }

    func animatedMonsterImage(_ monsterID: Int) async -> UIImage? {
        guard let resourceName = ClientScriptManager.shared.monsterResourceName(monsterID) else {
            return nil
        }

        let sprPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).spr")
        let actPath = GRF.Path(string: "data\\sprite\\몬스터\\\(resourceName).act")

        do {
            let sprData = try ClientBundle.shared.grf.contentsOfEntry(at: sprPath)
            let spr = try SPR(data: sprData)

            let actData = try ClientBundle.shared.grf.contentsOfEntry(at: actPath)
            let act = try ACT(data: actData)

            let sprites = spr.sprites.enumerated()
            let spritesByType = Dictionary(grouping: sprites, by: { $0.element.type })
            let imagesForSpritesByType = spritesByType.mapValues { sprites in
                sprites.map { sprite in
                    spr.image(forSpriteAt: sprite.offset)?.image
                }
            }

            let animatedImage = act.animatedImage(forActionAt: 0, imagesForSpritesByType: imagesForSpritesByType)
            let images = animatedImage.images.map(UIImage.init)
            let duration = animatedImage.delay * CGFloat(animatedImage.images.count)
            let uiImage = UIImage.animatedImage(with: images, duration: duration)
            return uiImage
        } catch {
            return nil
        }
    }

    func jobImage(sexID: Int, jobID: Int) async -> UIImage? {
        let sex = switch sexID {
        case RA_SEX_MALE: "여"
        case RA_SEX_FEMALE: "남"
        default: ""
        }

        let job = JobID(rawValue: jobID).resourceName

        let bodySPRPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(sex)\\\(job)_\(sex).spr")
        let bodyACTPath = GRF.Path(string: "data\\sprite\\인간족\\몸통\\\(sex)\\\(job)_\(sex).act")

        do {
            let sprData = try ClientBundle.shared.grf.contentsOfEntry(at: bodySPRPath)
            let spr = try SPR(data: sprData)

            let actData = try ClientBundle.shared.grf.contentsOfEntry(at: bodyACTPath)
            let act = try ACT(data: actData)

            let sprites = spr.sprites.enumerated()
            let spritesByType = Dictionary(grouping: sprites, by: { $0.element.type })
            let imagesForSpritesByType = spritesByType.mapValues { sprites in
                sprites.map { sprite in
                    spr.image(forSpriteAt: sprite.offset)?.image
                }
            }

            let animatedImage = act.animatedImage(forActionAt: 0, imagesForSpritesByType: imagesForSpritesByType)
            let images = animatedImage.images.map(UIImage.init)
            let duration = animatedImage.delay * CGFloat(animatedImage.images.count)
            let uiImage = images.first
            return uiImage
        } catch {
            return nil
        }
    }

    func skillIconImage(_ skillName: String) async -> UIImage? {
        let path = GRF.Path(string: "data\\sprite\\아이템\\\(skillName).spr")

        do {
            let sprData = try ClientBundle.shared.grf.contentsOfEntry(at: path)
            let spr = try SPR(data: sprData)
            guard let image = spr.image(forSpriteAt: 0) else {
                return nil
            }
            let uiImage = UIImage(cgImage: image.image)
            return uiImage
        } catch {
            return nil
        }
    }
}
