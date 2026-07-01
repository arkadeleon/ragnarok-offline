//
//  EffectViewerEffect.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import RagnarokConstants
import RagnarokEffects

struct EffectViewerEffect: Identifiable, Hashable {
    static var all: [EffectViewerEffect] {
        EffectTable.effectIDs.map(EffectViewerEffect.init(effectID:))
    }

    var effectID: EffectID

    var id: Int {
        effectID.rawValue
    }

    var displayName: String {
        effectID.stringValue
    }
}
