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
        var effectsByID: [Int : EffectViewerEffect] = [:]

        for effectID in EffectTable.effectIDs {
            effectsByID[effectID.rawValue] = EffectViewerEffect(effectID: effectID)
        }
        for rawEffectID in EffectManager.supportedRawEffectIDs {
            effectsByID[rawEffectID] = EffectViewerEffect(rawEffectID: rawEffectID)
        }
        if let ez2strEffectCatalog {
            for entry in ez2strEffectCatalog.entries {
                effectsByID[entry.rawEffectID] = EffectViewerEffect(
                    rawEffectID: entry.rawEffectID,
                    customName: entry.displayName
                )
            }
        }

        return effectsByID.values.sorted { $0.rawEffectID < $1.rawEffectID }
    }

    var rawEffectID: Int
    var customName: String?

    var effectID: EffectID? {
        EffectID(rawValue: rawEffectID)
    }

    var id: Int {
        rawEffectID
    }

    var displayName: String {
        if let customName {
            "#\(rawEffectID) \(customName)"
        } else if let effectID {
            "#\(rawEffectID) \(String(describing: effectID).uppercased())"
        } else {
            "#\(rawEffectID) BSON_\(rawEffectID)"
        }
    }

    init(rawEffectID: Int, customName: String? = nil) {
        self.rawEffectID = rawEffectID
        self.customName = customName
    }

    init(effectID: EffectID) {
        self.rawEffectID = effectID.rawValue
        self.customName = nil
    }
}
