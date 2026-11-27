//
//  RagEffect+Dispatch.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/26.
//

import Foundation

extension RagEffect {
    private nonisolated static let proceduralEffectIDs: [EffectID] =
        proceduralEffectIDs0000To0099
            + proceduralEffectIDs0100To0199
            + proceduralEffectIDs0200To0299
            + proceduralEffectIDs0300To0399
            + proceduralEffectIDs0400To0499
            + proceduralEffectIDs0500To0599
            + proceduralEffectIDs0600To0699
            + proceduralEffectIDs0700To0799
            + proceduralEffectIDs0800To0899
            + proceduralEffectIDs0900To0999
            + proceduralEffectIDs1000Plus

    private nonisolated static let proceduralEffectIDSet: Set<EffectID> = Set(proceduralEffectIDs)

    public nonisolated static let supportedEffectIDs: [EffectID] = Array(
        proceduralEffectIDSet.union(STRDefinition.definitions.map(\.effectID))
    ).sorted()

    public nonisolated static func supports(_ effectID: EffectID) -> Bool {
        proceduralEffectIDSet.contains(effectID) || STRDefinition.definition(for: effectID) != nil
    }

    static func makeProcedural(
        id: UUID,
        request: EffectSpawnRequest
    ) -> RagEffect? {
        guard proceduralEffectIDSet.contains(request.effectID) else {
            return nil
        }
        return RagEffect(id: id, request: request) { effect, context in
            effect.processEffect(context: context)
        }
    }

    static func make(
        id: UUID,
        request: EffectSpawnRequest,
        usesMinimalEffects: Bool = false
    ) -> RagEffect? {
        if let procedural = makeProcedural(id: id, request: request) {
            return procedural
        }

        if let definition = STRDefinition.definition(for: request.effectID) {
            let effect = RagEffect(id: id, request: request) { effect, context in
                effect.processSTRDefinition(definition, context: context)
            }
            effect.configureSTR(
                path: definition.resolveSTRPath(usesMinimalEffects: usesMinimalEffects),
                loopLimit: definition.loopLimit
            )
            return effect
        }

        return nil
    }

    func processEffect(context: EffectTickContext) -> Bool {
        switch effectID.rawValue {
        case 0...99:
            process0000To0099(context: context)
        case 100...199:
            process0100To0199(context: context)
        case 200...299:
            process0200To0299(context: context)
        case 300...399:
            process0300To0399(context: context)
        case 400...499:
            process0400To0499(context: context)
        case 500...599:
            process0500To0599(context: context)
        case 600...699:
            process0600To0699(context: context)
        case 700...799:
            process0700To0799(context: context)
        case 800...899:
            process0800To0899(context: context)
        case 900...999:
            process0900To0999(context: context)
        case 1000...:
            process1000Plus(context: context)
        default:
            false
        }
    }
}
