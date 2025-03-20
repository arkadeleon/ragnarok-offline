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
                DatabaseRecordSectionView("Info", attributes: statusChange.attributes)

                if !statusChange.fail.isEmpty {
                    DatabaseRecordSectionView("Fail") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(statusChange.fail) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.displayName)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }

                if !statusChange.endOnStart.isEmpty {
                    DatabaseRecordSectionView("End on Start") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(statusChange.endOnStart) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.displayName)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }

                if !statusChange.endReturn.isEmpty {
                    DatabaseRecordSectionView("End Return") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(statusChange.endReturn) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.displayName)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }

                if !statusChange.endOnEnd.isEmpty {
                    DatabaseRecordSectionView("End on End") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(statusChange.endOnEnd) { statusChange in
                                NavigationLink(value: statusChange) {
                                    Text(statusChange.displayName)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }

                if let localizedDescription = statusChange.localizedDescription {
                    DatabaseRecordSectionView("Description", text: localizedDescription)
                }

                if let script = statusChange.script?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    DatabaseRecordSectionView("Script", text: script, monospaced: true)
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
