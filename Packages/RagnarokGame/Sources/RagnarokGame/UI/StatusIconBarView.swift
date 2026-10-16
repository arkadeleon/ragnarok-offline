//
//  StatusIconBarView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/16.
//

import RagnarokCore
import RagnarokLocalization
import RagnarokModels
import RagnarokResources
import SwiftUI

struct StatusIconBarView: View {
    var statusChanges: [StatusChange]

    @Environment(GameContext.self) private var gameContext

    @State private var statusIconTable: StatusIconTable?
    @State private var presentedStatusID: Int?
    @State private var rowCount = 1
    @State private var isExpanded = false

    var body: some View {
        let statusChanges = statusChanges.filter { statusIconTable?.statusIconName(forStatusID: $0.statusID) != nil }

        // When collapsed, the bar holds 3 columns. If the icons do not fit, the last slot shows how many are hidden.
        let slotCount = rowCount * 3
        let isOverflowing = statusChanges.count > slotCount
        let maxCollapsedCount = slotCount - 1
        let visibleStatusChanges = isOverflowing && !isExpanded ? Array(statusChanges.prefix(maxCollapsedCount)) : statusChanges

        StatusIconLayout(horizontalSpacing: 8, verticalSpacing: 4) {
            ForEach(visibleStatusChanges, id: \.statusID) { statusChange in
                StatusIconView(statusChange: statusChange)
                    .onTapGesture {
                        presentedStatusID = statusChange.statusID == presentedStatusID ? nil : statusChange.statusID
                    }
                    .overlay(alignment: .topTrailing) {
                        if statusChange.statusID == presentedStatusID,
                           let description = gameContext.statusInfoTable.localizedStatusDescription(forStatusID: statusChange.statusID) {
                            StatusDescriptionView(description: description, endTime: statusChange.endTime)
                                .fixedSize()
                                .onTapGesture {
                                    presentedStatusID = nil
                                }
                                .offset(x: -25)
                        }
                    }
                    .zIndex(statusChange.statusID == presentedStatusID ? 1 : 0)
            }

            if isOverflowing {
                Button {
                    presentedStatusID = nil
                    isExpanded.toggle()
                } label: {
                    Group {
                        if isExpanded {
                            Image(systemName: "chevron.right")
                        } else {
                            Text(verbatim: "+\(statusChanges.count - maxCollapsedCount)")
                        }
                    }
                    .font(.game(size: 12))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 0, x: 1, y: 1)
                    .frame(width: 24, height: 24)
                    .background(.black.opacity(0.5))
                    .clipShape(.rect(cornerRadius: 3, style: .circular))
                    .overlay {
                        RoundedRectangle(cornerRadius: 3, style: .circular)
                            .strokeBorder(Color.gameBoxBorder)
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxHeight: .infinity, alignment: .topTrailing)
        .onGeometryChange(for: Int.self) { geometryProxy in
            // Each row is a 24-point icon plus 4 points of spacing.
            max(Int((geometryProxy.size.height + 4) / 28), 1)
        } action: { rowCount in
            self.rowCount = rowCount
        }
        .task {
            statusIconTable = await gameContext.resourceManager.statusIconTable()
        }
    }
}

/// Fills a column from the top, and starts a new column on the left when the height runs out.
private struct StatusIconLayout: Layout {
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(subviews, maxHeight: proposal.height ?? .infinity).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arrangement = arrange(subviews, maxHeight: bounds.height)
        for (subview, origin) in zip(subviews, arrangement.origins) {
            subview.place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
        }
    }

    private func arrange(_ subviews: Subviews, maxHeight: CGFloat) -> (origins: [CGPoint], size: CGSize) {
        var columns: [Int] = []
        var ys: [CGFloat] = []
        var columnWidths: [CGFloat] = []
        var height: CGFloat = 0

        var y: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if columnWidths.isEmpty || (y > 0 && y + size.height > maxHeight) {
                columnWidths.append(0)
                y = 0
            }
            columns.append(columnWidths.count - 1)
            ys.append(y)
            columnWidths[columnWidths.count - 1] = max(columnWidths[columnWidths.count - 1], size.width)
            height = max(height, y + size.height)
            y += size.height + verticalSpacing
        }

        let width = columnWidths.reduce(0, +) + horizontalSpacing * CGFloat(max(columnWidths.count - 1, 0))

        // The first column is on the right.
        var columnXs: [CGFloat] = []
        var trailingX = width
        for columnWidth in columnWidths {
            columnXs.append(trailingX - columnWidth)
            trailingX -= columnWidth + horizontalSpacing
        }

        let origins = zip(columns, ys).map { column, y in
            CGPoint(x: columnXs[column], y: y)
        }

        return (origins, CGSize(width: width, height: height))
    }
}

private struct StatusIconView: View {
    var statusChange: StatusChange

    @Environment(GameContext.self) private var gameContext

    @State private var iconImage: Resources.Image?

    var body: some View {
        ZStack {
            if let iconImage {
                Image(decorative: iconImage.cgImage, scale: 1)
                    .resizable()
                    .interpolation(.none)
            }

            if let duration = statusChange.duration {
                TimelineView(.animation(minimumInterval: 0.1)) { _ in
                    let sector = sector(duration: duration, now: .now)

                    if sector.progress > 0, sector.progress < 1 {
                        GameClockSector(startFraction: 0, endFraction: sector.progress)
                            .fill(sector.color)
                    }
                }
            }
        }
        .frame(width: 24, height: 24)
        .contentShape(.rect)
        .task(id: statusChange.statusID) {
            iconImage = try? await gameContext.resourceManager.statusIconImage(forStatusID: statusChange.statusID)
        }
    }

    /// The sector fills up over the last minute in orange, and over the time before it in white.
    private func sector(duration: Duration, now: ContinuousClock.Instant) -> (color: Color, progress: Double) {
        let remaining = max(now.duration(to: statusChange.startTime + duration), .zero)
        if remaining < .seconds(60) {
            return (Color(#colorLiteral(red: 1, green: 0.5882352941, blue: 0.1960784314, alpha: 0.65)), 1 - remaining / .seconds(60))
        } else {
            let progress = duration > .seconds(60) ? statusChange.startTime.duration(to: now) / (duration - .seconds(60)) : 0
            return (Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.65)), progress)
        }
    }
}

private struct StatusDescriptionView: View {
    var description: StatusDescription
    var endTime: ContinuousClock.Instant?

    @Environment(GameContext.self) private var gameContext

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            let remainingTime = remainingTimeText()

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(description.lines.enumerated()), id: \.offset) { _, line in
                    let text = line.text.replacingOccurrences(of: "%s", with: remainingTime)
                    if !text.isEmpty {
                        Text(text)
                            .foregroundStyle(line.color.flatMap({ Int($0.dropFirst(), radix: 16) }).map(Color.init(hex:)) ?? .white)
                            .frame(minHeight: 16)
                    }
                }
            }
        }
        .font(.game(size: 12))
        .shadow(color: .black, radius: 0, x: 1, y: 1)
        .padding(.horizontal, 5)
        .background(.black.opacity(0.5))
        .clipShape(.rect(cornerRadius: 3, style: .circular))
        .overlay {
            RoundedRectangle(cornerRadius: 3, style: .circular)
                .strokeBorder(Color.gameBoxBorder)
        }
    }

    /// An empty string when the status has no time limit, or its time is up.
    private func remainingTimeText() -> String {
        guard let endTime else {
            return ""
        }

        let remaining = ContinuousClock.now.duration(to: endTime)
        guard remaining > .zero else {
            return ""
        }

        let seconds = Int(remaining.components.seconds)

        let messageStringTable = gameContext.messageStringTable
        let secondsText = "\(seconds % 60) \(messageStringTable.localizedMessageString(forID: 1808))"
        if seconds >= 60 {
            return "\(seconds / 60) \(messageStringTable.localizedMessageString(forID: 1807)) \(secondsText)"
        } else {
            return secondsText
        }
    }
}

#Preview {
    let statusChanges = (1...20).map { statusID in
        StatusChange(statusID: statusID, startTime: .now, duration: statusID.isMultiple(of: 3) ? nil : .seconds(statusID * 20))
    }

    StatusIconBarView(statusChanges: statusChanges)
        .frame(width: 320, height: 160, alignment: .topTrailing)
        .padding()
        .environment(GameContext.testing)
}
