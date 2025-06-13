//
//  SharedDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/12.
//

import rAthenaResources
import RODatabase

extension ItemDatabase {
    static let shared = ItemDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}

extension JobDatabase {
    static let shared = JobDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}

extension MapDatabase {
    static let shared = MapDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}

extension MonsterDatabase {
    static let shared = MonsterDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}

extension MonsterSummonDatabase {
    static let shared = MonsterSummonDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}

extension NPCDatabase {
    static let shared = NPCDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}

extension PetDatabase {
    static let shared = PetDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}

extension SkillDatabase {
    static let shared = SkillDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}

extension SkillTreeDatabase {
    static let shared = SkillTreeDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}

extension StatusChangeDatabase {
    static let shared = StatusChangeDatabase(sourceURL: ServerResourceManager.default.sourceURL, mode: .renewal)
}
