//
//  MonsterDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .monster)

    var body: some View {
        DatabaseView(database: $database) { monsters in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .center, spacing: 30) {
                    ForEach(monsters) { monster in
                        NavigationLink(value: monster) {
                            MonsterGridCell(monster: monster, secondaryText: nil)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
        .navigationTitle("Monster Database")
    }
}

#Preview {
    MonsterDatabaseView()
}
