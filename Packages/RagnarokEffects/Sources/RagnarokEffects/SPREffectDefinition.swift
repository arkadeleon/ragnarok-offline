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
// - soundName:               wav
// - attachedToTarget:        attachedEntity
// - repeats:                 repeat
// - duration:                duration (converted from milliseconds to seconds)
// - isStackable:             stackable
// - rendersAtHead:           head
// - stopsAtEnd:              stopAtEnd
// - inheritsDirection:       direction
// - actionIndex:             frame
// - frameInterval:           delayFrame (converted from milliseconds to seconds)
// - spriteOffset:            xOffset, yOffset
// - rendersBeforeEntities:   renderBeforeEntities
public struct SPREffectDefinition: Sendable {
    public var fileName: String
    public var soundName: String?
    public var attachedToTarget: Bool
    public var repeats: Bool
    public var duration: TimeInterval?
    public var isStackable: Bool
    public var rendersAtHead: Bool
    public var stopsAtEnd: Bool
    public var inheritsDirection: Bool
    public var actionIndex: Int
    public var frameInterval: TimeInterval?
    public var spriteOffset: SIMD2<Float>
    public var rendersBeforeEntities: Bool
}

extension EffectDefinition {
    public static func spr(
        fileName: String,
        soundName: String? = nil,
        attachedToTarget: Bool,
        repeats: Bool = false,
        duration: TimeInterval? = nil,
        isStackable: Bool = false,
        rendersAtHead: Bool = false,
        stopsAtEnd: Bool = false,
        inheritsDirection: Bool = false,
        actionIndex: Int = 0,
        frameInterval: TimeInterval? = nil,
        spriteOffset: SIMD2<Float> = .zero,
        rendersBeforeEntities: Bool = false
    ) -> EffectDefinition {
        let definition = SPREffectDefinition(
            fileName: fileName,
            soundName: soundName,
            attachedToTarget: attachedToTarget,
            repeats: repeats,
            duration: duration,
            isStackable: isStackable,
            rendersAtHead: rendersAtHead,
            stopsAtEnd: stopsAtEnd,
            inheritsDirection: inheritsDirection,
            actionIndex: actionIndex,
            frameInterval: frameInterval,
            spriteOffset: spriteOffset,
            rendersBeforeEntities: rendersBeforeEntities
        )
        return .spr(definition)
    }
}
