//
//  ObservableSkillDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import Combine
import rAthenaCommon
import RODatabase

@MainActor
class ObservableSkillDatabase: ObservableObject {
    let mode: ServerMode

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var skills: [Skill] = []
    @Published var filteredSkills: [Skill] = []

    init(mode: ServerMode) {
        self.mode = mode
    }

    func fetchSkills() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        let database = SkillDatabase.database(for: mode)

        do {
            skills = try await database.skills()
            filterSkills()

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }
    }

    func filterSkills() {
        if searchText.isEmpty {
            filteredSkills = skills
        } else {
            filteredSkills = skills.filter { skill in
                skill.name.localizedStandardContains(searchText)
            }
        }
    }
}
