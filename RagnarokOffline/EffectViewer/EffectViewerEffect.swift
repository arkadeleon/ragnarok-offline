//
//  EffectViewerEffect.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import RagnarokEffects

struct EffectViewerEffect: Identifiable, Hashable {
    static var all: [EffectViewerEffect] {
        var ids = Set(EffectTable.effectIDs.map(\.rawValue))
        ids.formUnion(EffectManager.supportedRawEffectIDs)
        return ids.sorted().map(EffectViewerEffect.init(rawEffectID:))
    }

    var rawEffectID: Int

    var effectID: EffectID? {
        EffectID(rawValue: rawEffectID)
    }

    var id: Int {
        rawEffectID
    }

    var displayName: String {
        if let effectID {
            "#\(rawEffectID) \(String(describing: effectID).uppercased())"
        } else {
            "#\(rawEffectID) BSON_\(rawEffectID)"
        }
    }

    init(rawEffectID: Int) {
        self.rawEffectID = rawEffectID
    }

    init(effectID: EffectID) {
        self.rawEffectID = effectID.rawValue
    }
}
