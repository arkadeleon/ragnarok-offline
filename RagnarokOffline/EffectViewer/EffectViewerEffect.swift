//
//  EffectViewerEffect.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import RagnarokEffects

struct EffectViewerEffect: Identifiable, Hashable {
    static var all: [EffectViewerEffect] {
        EffectTable.effectIDs.map { EffectViewerEffect(id: $0) }
    }

    var id: Int

    var displayName: String {
        "Effect #\(id)"
    }

    var summary: String {
        let definitions = EffectTable.definitions(forEffectID: id)
        let kinds = definitions.map { definition in
            switch definition {
            case .`3D`: "3D"
            case .cylinder: "Cylinder"
            case .str: "STR"
            }
        }
        return kinds.joined(separator: ", ")
    }
}
