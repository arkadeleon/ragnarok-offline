//
//  SkillDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import RagnarokCore
import SwiftUI

struct SkillDetailView: View {
    var skill: SkillModel

    var body: some View {
        DatabaseRecordDetailView {
            DatabaseRecordSectionView(attributes: skill.attributes) {
                Text("Info", tableName: "Database")
            }

            if skill.showsSPCost || skill.showsCastTime || skill.showsFixedCastTime || skill.showsAfterCastActDelay || skill.showsCooldown || skill.showsRange {
                DatabaseRecordSectionView {
                    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                        GridRow {
                            Text("Level", tableName: "Database")
                            if skill.showsSPCost {
                                Text("SP", tableName: "Database")
                            }
                            if skill.showsCastTime {
                                Text("Cast Time", tableName: "Database")
                            }
                            if skill.showsFixedCastTime {
                                Text("Fixed Cast Time", tableName: "Database")
                            }
                            if skill.showsAfterCastActDelay {
                                Text("Delay", tableName: "Database")
                            }
                            if skill.showsCooldown {
                                Text("Cooldown", tableName: "Database")
                            }
                            if skill.showsRange {
                                Text("Range", tableName: "Database")
                            }
                        }
                        .foregroundStyle(Color.secondary)

                        ForEach(skill.levels) { level in
                            GridRow {
                                Text(level.level.formatted())
                                if skill.showsSPCost {
                                    Text(level.spCost.formatted())
                                }
                                if skill.showsCastTime {
                                    Text(formatTime(level.castTime))
                                }
                                if skill.showsFixedCastTime {
                                    Text(formatTime(level.fixedCastTime))
                                }
                                if skill.showsAfterCastActDelay {
                                    Text(formatTime(level.afterCastActDelay))
                                }
                                if skill.showsCooldown {
                                    Text(formatTime(level.cooldown))
                                }
                                if skill.showsRange {
                                    Text(level.range.formatted())
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } header: {
                    Text("Levels", tableName: "Database")
                }
            }

            if let localizedDescription = skill.localizedDescription {
                DatabaseRecordSectionView(text: AttributedString(description: localizedDescription)) {
                    Text("Description", tableName: "Database")
                }
            }
        }
        .navigationTitle(skill.displayName)
    }

    private func formatTime(_ milliseconds: Int) -> String {
        let measurement = Measurement(value: Double(milliseconds) / 1000, unit: UnitDuration.seconds)
        return measurement.formatted(.measurement(width: .narrow))
    }
}
