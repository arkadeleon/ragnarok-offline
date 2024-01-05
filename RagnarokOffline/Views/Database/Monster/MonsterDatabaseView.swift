//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaMap

struct MonsterDatabaseView: View {
    @State private var searchText = ""
    @State private var allRecords = [RAMonster]()
    @State private var filteredRecords = [RAMonster]()

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 32) {
                ForEach(filteredRecords, id: \.monsterID) { monster in
                    NavigationLink {
                        MonsterDetailView(monster: monster)
                    } label: {
                        MonsterGridCell(monster: monster)
                    }
                }
            }
            .padding(32)
        }
        .searchable(text: $searchText)
        .navigationTitle(RAMonsterDatabase.shared.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            Task {
                allRecords = RAMonsterDatabase.shared.allRecords() as! [RAMonster]
                filterRecords()
            }
        }
        .onSubmit(of: .search) {
            filterRecords()
        }
        .onChange(of: searchText) { _ in
            filterRecords()
        }
    }

    private func filterRecords() {
        if searchText.isEmpty {
            filteredRecords = allRecords
        } else {
            filteredRecords = allRecords.filter { record in
                record.recordTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    MonsterDatabaseView()
}
