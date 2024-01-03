//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaMap
import SwiftUI

struct ItemDatabaseView: View {
    @State private var searchText = ""
    @State private var allRecords = [RAItem]()
    @State private var filteredRecords = [RAItem]()

    public var body: some View {
        List(filteredRecords) { item in
            NavigationLink {
                ItemDetailView(item: item)
            } label: {
                ItemListRow(item: item)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText)
        .navigationTitle(RAItemDatabase.shared.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            Task {
                allRecords = RAItemDatabase.shared.allRecords() as! [RAItem]
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
    ItemDatabaseView()
}
