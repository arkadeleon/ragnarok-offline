//
//  StatusChangeInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/4.
//

import SwiftUI

struct StatusChangeInfoView: View {
    var statusChange: ObservableStatusChange

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                DatabaseRecordAttributesSectionView("Info", attributes: statusChange.attributes)

                if !statusChange.fail.isEmpty {
                    DatabaseRecordSectionView("Fail", spacing: 20) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(statusChange.fail) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.displayName)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if !statusChange.endOnStart.isEmpty {
                    DatabaseRecordSectionView("End on Start", spacing: 20) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(statusChange.endOnStart) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.displayName)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if !statusChange.endReturn.isEmpty {
                    DatabaseRecordSectionView("End Return", spacing: 20) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(statusChange.endReturn) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.displayName)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if !statusChange.endOnEnd.isEmpty {
                    DatabaseRecordSectionView("End on End", spacing: 20) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(statusChange.endOnEnd) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.displayName)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if let localizedDescription = statusChange.localizedDescription {
                    DatabaseRecordSectionView("Description") {
                        Text(localizedDescription)
                    }
                }

                if let script = statusChange.script {
                    DatabaseRecordSectionView("Script") {
                        Text(script.trimmingCharacters(in: .whitespacesAndNewlines))
                            .monospaced()
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(statusChange.displayName)
        .task {
            await statusChange.fetchDetail()
        }
    }
}
