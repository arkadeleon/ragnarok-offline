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

    @Published var status: AsyncContentStatus<[Skill]> = .notYetLoaded
    @Published var searchText = ""
    @Published var filteredSkills: [Skill] = []

    init(database: Database) {
        self.database = database
    }

    func fetchSkills() {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        Task {
            do {
                let skills = try await database.skills().joined()
                status = .loaded(skills)
                filterSkills()
            } catch {
                status = .failed(error)
            }
        }
    }

    func filterSkills() {
        guard case .loaded(let skills) = status else {
            return
        }

        if searchText.isEmpty {
            filteredSkills = skills
        } else {
            Task {
                filteredSkills = skills.filter { skill in
                    skill.name.localizedStandardContains(searchText)
                }
            }
        }
    }
}
