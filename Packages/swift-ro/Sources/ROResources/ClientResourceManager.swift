//
//  ClientResourceManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//

import CoreGraphics
import RODatabase
import ROFileFormats

public class ClientResourceManager {
    public static let shared = ClientResourceManager()

    public func monsterImage(_ monsterID: Int) async -> CGImage? {
        guard let resourceName = await ClientDatabase.shared.monsterResourceName(for: monsterID) else {
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

    public func jobImage(gender: Gender, job: Job) async -> CGImage? {
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
