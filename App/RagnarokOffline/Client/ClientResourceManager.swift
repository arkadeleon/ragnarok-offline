//
//  ClientResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import CoreGraphics
import rAthenaCommon
import RagnarokOfflineFileFormats

class ClientResourceManager {
    static let shared = ClientResourceManager()

    func monsterImage(_ monsterID: Int) async -> CGImage? {
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
            let image = animatedImage.images.first
            return image
        } catch {
            return nil
        }
    }

    func jobImage(gender: Gender, job: Job) async -> CGImage? {
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
            let image = animatedImage.images.first
            return image
        } catch {
            return nil
        }
    }
}
