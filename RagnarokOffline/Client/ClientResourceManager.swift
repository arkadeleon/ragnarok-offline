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

    func itemIconImage(_ itemID: Int) async -> UIImage? {
        guard let resourceName = ClientDatabase.shared.itemResourceName(itemID) else {
            return nil
        }

        let path = ClientBundle.shared.itemIconPath(forResourceName: resourceName)

        do {
            let bmpData = try ClientBundle.shared.grf.contentsOfEntry(at: path)
            let image = UIImage(bmpData: bmpData)
            return image
        } catch {
            return nil
        }
    }

    func itemPreviewImage(_ itemID: Int) async -> UIImage? {
        guard let resourceName = ClientDatabase.shared.itemResourceName(itemID) else {
            return nil
        }

        let path = ClientBundle.shared.itemPreviewPath(forResourceName: resourceName)

        do {
            let bmpData = try ClientBundle.shared.grf.contentsOfEntry(at: path)
            let image = UIImage(bmpData: bmpData)
            return image
        } catch {
            return nil
        }
    }

    func monsterImage(_ monsterID: Int, size: CGSize) async -> UIImage? {
        guard let resourceName = ClientDatabase.shared.monsterResourceName(monsterID) else {
            return nil
        }

        let (path, _) = ClientBundle.shared.monsterSpritePath(forResourceName: resourceName)

        print("Load: " + path.string)

        do {
            let sprData = try ClientBundle.shared.grf.contentsOfEntry(at: path)
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

        let (sprPath, actPath) = ClientBundle.shared.monsterSpritePath(forResourceName: resourceName)

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

    func jobImage(gender: Gender, job: Job, size: CGSize) async -> UIImage? {
        let (bodySPRPath, bodyACTPath) = ClientBundle.shared.bodySpritePath(forGender: gender, job: job)

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

    func skillIconImage(_ skillName: String) async -> UIImage? {
        let path = ClientBundle.shared.skillIconPath(forResourceName: skillName)

        do {
            let bmpData = try ClientBundle.shared.grf.contentsOfEntry(at: path)
            let image = UIImage(bmpData: bmpData)
            return image
        } catch {
            return nil
        }
    }

    func mapPreviewImage(_ mapName: String, size: CGSize) async -> UIImage? {
        let path = ClientBundle.shared.mapPreviewPath(forResourceName: mapName)

        do {
            let bmpData = try ClientBundle.shared.grf.contentsOfEntry(at: path)
            let image = UIImage(bmpData: bmpData)
            return image?.resize(size.width, size.height)
        } catch {
            return nil
        }
    }
}
