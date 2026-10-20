//
//  DatabaseFormatting.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import Foundation

/// Formats a time in milliseconds with the largest allowed units that fit, such as `150ms`, `1s 872ms` or `4m 30s`.
/// Pass `[.milliseconds]` to show every time in milliseconds, such as `1,872ms`.
func formatTime(_ milliseconds: Int, allowedUnits: Set<Duration.UnitsFormatStyle.Unit> = [.hours, .minutes, .seconds, .milliseconds]) -> String {
    Duration.milliseconds(milliseconds).formatted(.units(allowed: allowedUnits, width: .narrow))
}

/// Formats a distance in map cells, such as `1 cell` or `9 cells`.
func formatCells(_ cells: Int) -> String {
    String(AttributedString(localized: "^[\(cells) cell](inflect: true)", table: "Database").characters)
}

/// Formats a rate as a percentage, where `base` is 100%. For example, a drop rate of 2500 with a base of
/// 10000 is `25%`.
func formatRate(_ rate: Int, base: Int) -> String {
    (Double(rate) / Double(base)).formatted(.percent)
}

/// Formats an amount of zeny, such as `1,500 Z`.
func formatZeny(_ zeny: Int) -> String {
    zeny.formatted() + " Z"
}

/// Formats a weight in tenths, such as `2000` for a weight of 20000.
func formatWeight(_ weight: Int) -> String {
    (Double(weight) / 10).formatted()
}
