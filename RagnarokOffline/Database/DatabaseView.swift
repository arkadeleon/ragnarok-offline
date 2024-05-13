//
//  DatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI

struct DatabaseView<RecordProvider, Content>: View where RecordProvider: DatabaseRecordProvider, Content: View {
    @Binding var database: ObservableDatabase<RecordProvider>
    var content: ([RecordProvider.Record]) -> Content

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var searchFieldPlacement: SearchFieldPlacement {
        if horizontalSizeClass == .compact {
            .navigationBarDrawer(displayMode: .always)
        } else {
            .automatic
        }
    }

    var body: some View {
        content(database.filteredRecords)
            .overlay {
                if database.loadStatus == .loading {
                    ProgressView()
                }
            }
            .overlay {
                if database.loadStatus == .loaded && database.filteredRecords.isEmpty {
                    EmptyContentView("No Records")
                }
            }
            .databaseNavigationDestinations(mode: database.mode)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .searchable(text: $database.searchText, placement: searchFieldPlacement)
            .onSubmit(of: .search) {
                database.filterRecords()
            }
            .onChange(of: database.searchText) {
                database.filterRecords()
            }
            .task {
                await database.fetchRecords()
            }
    }

    init(database: Binding<ObservableDatabase<RecordProvider>>, @ViewBuilder content: @escaping ([RecordProvider.Record]) -> Content) {
        _database = database
        self.content = content
    }
}

#Preview {
    DatabaseView(database: .constant(.init(mode: .renewal, recordProvider: .monsterSummon))) { records in
        List(records) { record in
            Text(record.monsterSummon.group)
        }
    }
}
