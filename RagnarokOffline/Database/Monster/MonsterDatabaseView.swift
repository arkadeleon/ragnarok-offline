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
            ImageGrid {
                ForEach(monsters) { monster in
                    NavigationLink(value: monster) {
                        MonsterGridCell(monster: monster, secondaryText: nil)
                    }
                    .buttonStyle(.plain)
                }
            }
        } empty: {
            ContentUnavailableView("No Monsters", systemImage: "pawprint.fill")
        }
        .navigationTitle("Monster Database")
    }
}

#Preview {
    MonsterDatabaseView()
}
