//
//  MapObjectHit.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/30.
//

import RagnarokConstants
import RagnarokModels

struct MapObjectHit {
    struct Combo {
        var damage: Int
        var isFinal: Bool
    }

    /// Time between two hits of a multi-hit attack.
    static let multiHitInterval: Duration = .milliseconds(200)

    var delay: Duration
    var damage: Int

    /// Damage accumulated up to this hit.
    var combo: MapObjectHit.Combo?
}

extension MapObjectHit {
    static func hits(for objectAction: MapObjectAction) -> [MapObjectHit] {
        let attackDelay: Duration = .milliseconds(objectAction.sourceSpeed)
        let damage = objectAction.damage
        let damage2 = objectAction.damage2
        let multiHitInterval = MapObjectHit.multiHitInterval

        var hits: [MapObjectHit] = []

        switch objectAction.type {
        case .normal, .endure, .critical:
            let hit = MapObjectHit(delay: attackDelay, damage: damage)
            hits.append(hit)

            if damage2 > 0 {
                let hit2 = MapObjectHit(delay: attackDelay + multiHitInterval * 1.75, damage: damage2)
                hits.append(hit2)
            }
        case .multi_hit, .multi_hit_endure, .multi_hit_critical:
            // The damage is shown in two halves, unless it is too small to be divided.
            let count = damage > 1 ? 2 : 1
            let hitDamage = damage / count
            let showsCombo = damage > 0

            if count == 2 {
                let hit = MapObjectHit(
                    delay: attackDelay,
                    damage: hitDamage,
                    combo: showsCombo ? MapObjectHit.Combo(damage: hitDamage, isFinal: false) : nil
                )
                hits.append(hit)
            }

            if damage2 > 0 {
                let hit = MapObjectHit(
                    delay: attackDelay + multiHitInterval / 2,
                    damage: hitDamage,
                    combo: showsCombo ? MapObjectHit.Combo(damage: damage, isFinal: false) : nil
                )
                hits.append(hit)

                let hit2 = MapObjectHit(
                    delay: attackDelay + multiHitInterval * 1.75,
                    damage: damage2,
                    combo: showsCombo ? MapObjectHit.Combo(damage: damage + damage2, isFinal: true) : nil
                )
                hits.append(hit2)
            } else {
                let hit = MapObjectHit(
                    delay: attackDelay + multiHitInterval,
                    damage: hitDamage,
                    combo: showsCombo ? MapObjectHit.Combo(damage: damage, isFinal: true) : nil
                )
                hits.append(hit)
            }
        default:
            break
        }

        return hits
    }

    static func hits(for objectSkill: MapObjectSkill) -> [MapObjectHit] {
        let damage = objectSkill.damage
        let count = objectSkill.count

        // A negative damage means the skill does not deal damage.
        guard damage >= 0, count > 0 else {
            return []
        }

        let showsCombo = count > 1 && damage > 0

        let hits = (0..<count).map { i in
            MapObjectHit(
                delay: .milliseconds(objectSkill.attackDelay) + MapObjectHit.multiHitInterval * i,
                damage: damage / count,
                combo: showsCombo ? MapObjectHit.Combo(damage: damage * (i + 1) / count, isFinal: i + 1 == count) : nil
            )
        }
        return hits
    }
}
