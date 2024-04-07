//
//  ObservableSkillDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Combine
import rAthenaDatabase

@MainActor
class ObservableSkillDatabase: ObservableObject {
    let database: Database

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var skills: [Skill] = []
    @Published var filteredSkills: [Skill] = []

    init(database: Database) {
        self.database = database
    }

    func fetchSkills() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

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
