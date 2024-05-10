//
//  ObservableMonsterSummonDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import Combine
import rAthenaCommon
import RODatabase

@MainActor
class ObservableMonsterSummonDatabase: ObservableObject {
    let mode: ServerMode

    @Published var loadStatus: LoadStatus = .notYetLoaded
    @Published var searchText = ""
    @Published var monsterSummons: [ObservableMonsterSummon] = []
    @Published var filteredMonsterSummons: [ObservableMonsterSummon] = []

    init(mode: ServerMode) {
        self.mode = mode
    }

    func fetchMonsterSummons() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        let monsterSummonDatabase = MonsterSummonDatabase.database(for: mode)

        do {
            let mss = try await monsterSummonDatabase.monsterSummons()

            var monsterSummons: [ObservableMonsterSummon] = []
            for ms in mss {
                let monsterSummon = ObservableMonsterSummon(mode: mode, monsterSummon: ms)
                monsterSummons.append(monsterSummon)
            }
            self.monsterSummons = monsterSummons

            filterMonsterSummons()

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }
    }

    func filterMonsterSummons() {
        if searchText.isEmpty {
            filteredMonsterSummons = monsterSummons
        } else {
            filteredMonsterSummons = monsterSummons.filter { monsterSummon in
                monsterSummon.monsterSummon.group.localizedStandardContains(searchText)
            }
        }
    }
}
