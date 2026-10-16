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

    var body: some View {
        StatusIconLayout(horizontalSpacing: 13, verticalSpacing: 4) {
            if let statusIconTable {
                ForEach(statusChanges.filter({ statusIconTable.statusIconName(forStatusID: $0.statusID) != nil }), id: \.statusID) { statusChange in
                    StatusIconView(statusChange: statusChange)
                        .onTapGesture {
                            presentedStatusID = statusChange.statusID == presentedStatusID ? nil : statusChange.statusID
                        }
                        .anchorPreference(key: StatusIconBoundsPreferenceKey.self, value: .bounds) { anchor in
                            [statusChange.statusID: anchor]
                        }
                }
            }
        }
        .overlayPreferenceValue(StatusIconBoundsPreferenceKey.self) { anchors in
            GeometryReader { geometry in
                if let statusChange = statusChanges.first(where: { $0.statusID == presentedStatusID }),
                   let anchor = anchors[statusChange.statusID],
                   let description = gameContext.statusInfoTable.localizedStatusDescription(forStatusID: statusChange.statusID) {
                    let iconBounds = geometry[anchor]

                    // The trailing edge of the description sits 1 point to the left of the icon.
                    StatusDescriptionView(description: description, endTime: statusChange.endTime)
                        .fixedSize()
                        .frame(width: 0, height: 0, alignment: .topTrailing)
                        .offset(x: iconBounds.minX - 1, y: iconBounds.minY)
                }
            }
        }
        .task {
            statusIconTable = await gameContext.resourceManager.statusIconTable()
        }
    }
}

private struct StatusIconBoundsPreferenceKey: PreferenceKey {
    static let defaultValue: [Int : Anchor<CGRect>] = [:]

    static func reduce(value: inout [Int : Anchor<CGRect>], nextValue: () -> [Int : Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
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
                    Canvas { context, size in
                        let now = ContinuousClock.now
                        let remaining = max(now.duration(to: statusChange.startTime + duration), .zero)

                        // The sector fills up over the last minute in orange, and over the time before it in white.
                        let color: Color
                        let progress: Double
                        if remaining < .seconds(60) {
                            color = Color(#colorLiteral(red: 1, green: 0.5882352941, blue: 0.1960784314, alpha: 0.65))
                            progress = 1 - remaining / .seconds(60)
                        } else {
                            color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.65))
                            progress = duration > .seconds(60) ? statusChange.startTime.duration(to: now) / (duration - .seconds(60)) : 0
                        }

                        guard progress > 0 else {
                            return
                        }

                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radius = hypot(size.width, size.height) / 2

                        var path = Path()
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: .degrees(-90), endAngle: .degrees(-90 + min(progress, 1) * 360), clockwise: false)
                        path.closeSubpath()

                        context.fill(path, with: .color(color))
                    }
                }
            }
        }
        .frame(width: 32, height: 32)
        .contentShape(.rect)
        .task(id: statusChange.statusID) {
            iconImage = try? await gameContext.resourceManager.statusIconImage(forStatusID: statusChange.statusID)
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
        .clipShape(.rect(cornerRadius: 3))
        .overlay {
            RoundedRectangle(cornerRadius: 3)
                .strokeBorder(Color.gameBoxBorder)
        }
    }

    /// An empty string when the status has no time limit, or its time is up.
    private func remainingTimeText() -> String {
        guard let endTime else {
            return ""
        }

        let seconds = Int(ContinuousClock.now.duration(to: endTime).components.seconds)
        guard seconds > 0 else {
            return ""
        }

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
    let statusChanges = [
        StatusChange(statusID: 10, startTime: .now, duration: .seconds(240)),
        StatusChange(statusID: 12, startTime: .now, duration: .seconds(70)),
        StatusChange(statusID: 35, startTime: .now, duration: nil),
    ]

    StatusIconBarView(statusChanges: statusChanges)
        .frame(width: 320, height: 200, alignment: .topTrailing)
        .padding()
        .environment(GameContext.testing)
}
