//
//  BaseLevelTableView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct BaseLevelTableView: View {
    var job: JobModel

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(job.baseLevels) { levelStats in
                        HStack {
                            Text(levelStats.level.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                            Text(levelStats.baseExp.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)

                            Text(levelStats.baseHp.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)

                            Text(levelStats.baseSp.formatted())
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.secondary)
                        }
                        .levelTableRow(level: levelStats.level)
                    }
                } header: {
                    HStack {
                        Text("Base Level", tableName: "Database")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        Text("Base Exp", tableName: "Database")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        Text("Base HP", tableName: "Database")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        Text("Base SP", tableName: "Database")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .levelTableHeader()
                }
            }
            .padding(.horizontal, hSpacing(sizeClass))
        }
        .background(.background)
        .navigationTitle(Text("Base Levels", tableName: "Database"))
    }
}

extension View {
    /// Pads a row of a level table, and shades every other row so that a long table is easier to follow.
    func levelTableRow(level: Int) -> some View {
        padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(level.isMultiple(of: 2) ? Color.secondary.opacity(0.1) : Color.clear, in: .rect(cornerRadius: 6, style: .circular))
    }

    /// Pads the header of a level table like its rows, and gives it a background so that it hides the rows
    /// that scroll under it.
    func levelTableHeader() -> some View {
        fontWeight(.semibold)
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(.background)
    }
}
