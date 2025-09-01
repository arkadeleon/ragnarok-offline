//
//  StatusChangeDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI

struct StatusChangeDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredStatusChanges: [StatusChangeModel] = []

    var body: some View {
        AdaptiveView {
            List(filteredStatusChanges) { statusChange in
                NavigationLink(value: statusChange) {
                    StatusChangeCell(statusChange: statusChange)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(filteredStatusChanges) { statusChange in
                NavigationLink(value: statusChange) {
                    StatusChangeCell(statusChange: statusChange)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Status Change Database")
        .background(.background)
        .overlay {
            if database.statusChanges.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredStatusChanges.isEmpty {
                ContentUnavailableView("No Results", systemImage: "moon.zzz.fill")
            }
        }
        .searchable(text: $searchText)
        .task(id: searchText) {
            filteredStatusChanges = await statusChanges(matching: searchText, in: database.statusChanges)
        }
        .task {
            await database.fetchStatusChanges()
            filteredStatusChanges = await statusChanges(matching: searchText, in: database.statusChanges)
        }
    }

    private func statusChanges(matching searchText: String, in statusChanges: [StatusChangeModel]) async -> [StatusChangeModel] {
        if searchText.isEmpty {
            return statusChanges
        }

        let filteredStatusChanges = statusChanges.filter { statusChange in
            statusChange.displayName.localizedStandardContains(searchText)
        }
        return filteredStatusChanges
    }
}

#Preview("Pre-Renewal Status Change Database") {
    NavigationStack {
        StatusChangeDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal))
}

#Preview("Renewal Status Change Database") {
    NavigationStack {
        StatusChangeDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal))
}
