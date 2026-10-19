//
//  StatusChangeDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import RagnarokResources
import SwiftUI

struct StatusChangeDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredStatusChanges: [StatusChangeModel] = []

    var body: some View {
        SizeClassAdaptiveView {
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
        .background(.background)
        .navigationTitle(Text("Status Change Database", tableName: "Database"))
        .adaptiveSearch(text: $searchText)
        .overlay {
            if database.statusChanges.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredStatusChanges.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("No Results", tableName: "Database")
                    } icon: {
                        Image(systemName: "moon.zzz.fill")
                    }
                }
            }
        }
        .task(id: "\(searchText)") {
            await database.fetchStatusChanges()

            if !searchText.isEmpty {
                do {
                    try await Task.sleep(for: .milliseconds(200))
                } catch {
                    return
                }
            }

            let filteredStatusChanges = await statusChanges(matching: searchText)
            if !Task.isCancelled {
                self.filteredStatusChanges = filteredStatusChanges
            }
        }
    }

    private func statusChanges(matching searchText: String) async -> [StatusChangeModel] {
        let statusChanges = database.statusChanges

        if searchText.isEmpty {
            return statusChanges
        }

        let indices = await database.statusChangeSearchIndex.indices(matching: searchText)
        return indices.map { statusChanges[$0] }
    }
}

#Preview("Pre-Renewal Status Change Database") {
    NavigationStack {
        StatusChangeDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .prerenewal, resourceManager: .previewing))
}

#Preview("Renewal Status Change Database") {
    NavigationStack {
        StatusChangeDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
