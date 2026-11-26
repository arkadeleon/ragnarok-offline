//
//  EffectViewerEffect.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import RagnarokEffects

struct EffectViewerEffect: Identifiable, Hashable {
    static var all: [EffectViewerEffect] {
        all(ez2strEffectCatalog: nil)
    }

    static func all(ez2strEffectCatalog: EZ2STREffectCatalog?) -> [EffectViewerEffect] {
        var effectsByID: [EffectID : EffectViewerEffect] = [:]

        for effectID in EffectManager.builtInEffectIDs {
            effectsByID[effectID] = EffectViewerEffect(effectID: effectID)
        }
        if let ez2strEffectCatalog {
            for entry in ez2strEffectCatalog.entries {
                effectsByID[entry.effectID] = EffectViewerEffect(
                    effectID: entry.effectID,
                    customName: entry.displayName
                )
            }
        }

        return effectsByID.values.sorted { $0.effectID < $1.effectID }
    }

    var effectID: EffectID
    var customName: String?

    var id: EffectID {
        effectID
    }

    var displayName: String {
        if let customName {
            "#\(effectID.rawValue) \(customName)"
        } else if let name = effectID.name {
            "#\(effectID.rawValue) \(name.uppercased())"
        } else {
            "#\(effectID.rawValue) BSON_\(effectID.rawValue)"
        }
    }

    init(effectID: EffectID, customName: String? = nil) {
        self.effectID = effectID
        self.customName = customName
    }
}
