//
//  EffectInstance.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation

@MainActor
public protocol EffectInstance: AnyObject {
    var id: UUID { get }
    var rawEffectID: Int { get }
    var ownerObjectID: EffectTargetID? { get }
    var attachmentKey: EffectAttachmentKey { get }
    var isAlive: Bool { get }

    func tick(context: EffectTickContext)
    func stop()
}
