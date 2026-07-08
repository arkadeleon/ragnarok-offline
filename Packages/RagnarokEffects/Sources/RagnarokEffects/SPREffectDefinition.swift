//
//  SPREffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/7/2.
//

import Foundation
import simd

// Ported from roBrowserLegacy EffectTable.js / spamSprite (Swift property -> JS key):
// - fileName:                file
// - actionIndex:             frame
// - frameInterval:           delayFrame (converted from milliseconds to seconds)
// - soundName:               wav
// - duration:                duration (converted from milliseconds to seconds)
// - repeats:                 repeat
// - stopsAtEnd:              stopAtEnd
// - isStackable:             stackable
// - attachedToTarget:        attachedEntity
// - rendersBeforeEntities:   renderBeforeEntities
// - rendersAtHead:           head
// - spriteOffset:            xOffset, yOffset
// - inheritsDirection:       direction
public struct SPREffectDefinition: Sendable {
    public var fileName: String
    public var actionIndex: Int
    public var frameInterval: TimeInterval?
    public var soundName: String?

    public var duration: TimeInterval?
    public var repeats: Bool
    public var stopsAtEnd: Bool
    public var isStackable: Bool

    public var attachedToTarget: Bool
    public var rendersBeforeEntities: Bool
    public var rendersAtHead: Bool

    public var spriteOffset: SIMD2<Float>
    public var inheritsDirection: Bool
}

extension EffectDefinition {
    public static func spr(
        fileName: String,
        actionIndex: Int = 0,
        frameInterval: TimeInterval? = nil,
        soundName: String? = nil,
        duration: TimeInterval? = nil,
        repeats: Bool = false,
        stopsAtEnd: Bool = false,
        isStackable: Bool = false,
        attachedToTarget: Bool,
        rendersBeforeEntities: Bool = false,
        rendersAtHead: Bool = false,
        spriteOffset: SIMD2<Float> = .zero,
        inheritsDirection: Bool = false
    ) -> EffectDefinition {
        let definition = SPREffectDefinition(
            fileName: fileName,
            actionIndex: actionIndex,
            frameInterval: frameInterval,
            soundName: soundName,
            duration: duration,
            repeats: repeats,
            stopsAtEnd: stopsAtEnd,
            isStackable: isStackable,
            attachedToTarget: attachedToTarget,
            rendersBeforeEntities: rendersBeforeEntities,
            rendersAtHead: rendersAtHead,
            spriteOffset: spriteOffset,
            inheritsDirection: inheritsDirection
        )
        return .spr(definition)
    }
}
