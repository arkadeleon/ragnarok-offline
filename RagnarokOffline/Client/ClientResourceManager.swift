//
//  ClientResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaCommon
import rAthenaDatabase
import UIKit

class ClientResourceManager {
    static let shared = ClientResourceManager()

    func itemIconImage(_ itemID: Int, size: CGSize) async -> UIImage? {
        guard let resourceName = ClientDatabase.shared.itemResourceName(itemID) else {
            return nil
        }

        let file = ClientResourceBundle.shared.itemIconFile(forResourceName: resourceName)
        guard let bmpData = file.contents() else {
            return nil
        }

        let image = UIImage(bmpData: bmpData)
        return image?.resize(size.width, size.height)
    }

    func itemPreviewImage(_ itemID: Int) async -> UIImage? {
        guard let resourceName = ClientDatabase.shared.itemResourceName(itemID) else {
            return nil
        }

        let file = ClientResourceBundle.shared.itemPreviewFile(forResourceName: resourceName)
        guard let bmpData = file.contents() else {
            return nil
        }

        let image = UIImage(bmpData: bmpData)
        return image
    }

    func monsterImage(_ monsterID: Int, size: CGSize) async -> UIImage? {
        guard let resourceName = ClientDatabase.shared.monsterResourceName(monsterID) else {
            return nil
        }

        let (sprFile, _) = ClientResourceBundle.shared.monsterSpriteFile(forResourceName: resourceName)
        guard let sprData = sprFile.contents() else {
            return nil
        }

        do {
            let spr = try SPR(data: sprData)
            guard let image = spr.image(forSpriteAt: 0) else {
                return nil
            }
            let uiImage = UIImage(cgImage: image.image)
            if uiImage.size.width > size.width || uiImage.size.height > size.height {
                return uiImage.resize(size.width, size.height)
            } else {
                return uiImage
            }
        } catch {
            return nil
        }
    }

    func animatedMonsterImage(_ monsterID: Int) async -> UIImage? {
        guard let resourceName = ClientDatabase.shared.monsterResourceName(monsterID) else {
            return nil
        }

        let (sprFile, actFile) = ClientResourceBundle.shared.monsterSpriteFile(forResourceName: resourceName)
        guard let sprData = sprFile.contents(), let actData = actFile.contents() else {
            return nil
        }

        do {
            let spr = try SPR(data: sprData)
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

    func jobImage(gender: Gender, job: Job, size: CGSize) async -> UIImage? {
        let bodyFile = ClientResourceBundle.shared.bodySpriteFile(forGender: gender, job: job)

        guard let sprData = bodyFile.spr.contents(), let actData = bodyFile.act.contents() else {
            return nil
        }

        do {
            let spr = try SPR(data: sprData)
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
            guard let uiImage = images.first else {
                return nil
            }
            if uiImage.size.width > size.width || uiImage.size.height > size.height {
                return uiImage.resize(size.width, size.height)
            } else {
                return uiImage
            }
        } catch {
            return nil
        }
    }

    func skillIconImage(_ skillName: String, size: CGSize) async -> UIImage? {
        let file = ClientResourceBundle.shared.skillIconFile(forResourceName: skillName)
        guard let bmpData = file.contents() else {
            return nil
        }

        let image = UIImage(bmpData: bmpData)
        return image?.resize(size.width, size.height)
    }

    func mapPreviewImage(_ mapName: String, size: CGSize) async -> UIImage? {
        let file = ClientResourceBundle.shared.mapPreviewFile(forResourceName: mapName)
        guard let bmpData = file.contents() else {
            return nil
        }

        let image = UIImage(bmpData: bmpData)
        return image?.resize(size.width, size.height)
    }
}
