//
//  GameVerticalTabBar.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/29.
//

import SwiftUI

struct GameVerticalTabBar<Tab>: View where Tab: Hashable {
    var tabs: [Tab]
    @Binding var selection: Tab
    var label: (Tab) -> Text

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element) { index, tab in
                Button {
                    selection = tab
                } label: {
                    GameVerticalTabBar_TabLabelLayout {
                        label(tab)
                            .font(.game(size: 11))
                            .foregroundStyle(tab == selection ? Color(#colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)) : Color(#colorLiteral(red: 0.462745098, green: 0.462745098, blue: 0.462745098, alpha: 1)))
                            .fixedSize()
                            .rotationEffect(.degrees(-90))
                    }
                    .offset(x: 2, y: -1.5)
                    .padding(.vertical, 4)
                    .frame(width: 20)
                    .frame(minHeight: 26)
                    .fixedSize(horizontal: false, vertical: true)
                    .background {
                        GameVerticalTabBar_TabBackground(
                            isSelected: tab == selection,
                            isFirst: index == 0,
                            isLast: index == tabs.count - 1,
                            isPreviousSelected: index > 0 && tabs[index - 1] == selection
                        )
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .zIndex(tab == selection ? 1 : 0)
            }
        }
        .frame(width: 20)
    }
}

/// Sizes a label turned 90 degrees by its turned bounds, so the label's width becomes the tab's height.
private struct GameVerticalTabBar_TabLabelLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let size = subviews.first?.sizeThatFits(.unspecified) ?? .zero
        return CGSize(width: size.height, height: size.width)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let subview = subviews.first else {
            return
        }
        let size = subview.sizeThatFits(.unspecified)
        subview.place(at: CGPoint(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: ProposedViewSize(size))
    }
}

private struct GameVerticalTabBar_TabBackground: View {
    var isSelected: Bool
    var isFirst: Bool
    var isLast: Bool
    var isPreviousSelected: Bool

    var body: some View {
        if isSelected {
            GameVerticalTabBar_SelectedTabShape(isFirst: isFirst)
                .fill(Color.white)
                .overlay {
                    GameVerticalTabBar_SelectedTabEdges(isFirst: isFirst)
                        .stroke(Color(#colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1)), lineWidth: 1)
                }
        } else {
            GameVerticalTabBar_TabShape(isFirst: isFirst, isLast: isLast)
                .fill(Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)))
                .overlay {
                    GameVerticalTabBar_TabEdges(isFirst: isFirst, isLast: isLast, isPreviousSelected: isPreviousSelected)
                        .stroke(Color(#colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1)), lineWidth: 1)
                }
        }
    }
}

private struct GameVerticalTabBar_TabShape: Shape {
    var isFirst: Bool
    var isLast: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 5, y: isFirst ? 0 : -3))
        path.addLine(to: CGPoint(x: 19, y: 0))
        path.addLine(to: CGPoint(x: 19, y: rect.maxY))
        path.addLine(to: CGPoint(x: 5, y: isLast ? rect.maxY - 3 : rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct GameVerticalTabBar_TabEdges: Shape {
    var isFirst: Bool
    var isLast: Bool
    var isPreviousSelected: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 5.5, y: isFirst ? 0 : -3))
        path.addLine(to: CGPoint(x: 5.5, y: isLast ? rect.maxY - 3 : rect.maxY))
        path.move(to: CGPoint(x: 18.5, y: 0))
        path.addLine(to: CGPoint(x: 18.5, y: rect.maxY))
        if !isFirst && !isPreviousSelected {
            path.move(to: CGPoint(x: 5, y: -3.5))
            path.addLine(to: CGPoint(x: 19, y: -0.5))
        }
        if isLast {
            path.move(to: CGPoint(x: 5, y: rect.maxY - 3.5))
            path.addLine(to: CGPoint(x: 19, y: rect.maxY - 0.5))
        }
        return path
    }
}

private struct GameVerticalTabBar_SelectedTabShape: Shape {
    var isFirst: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 3, y: 0))
        if isFirst {
            path.addLine(to: CGPoint(x: 20, y: 0))
        } else {
            path.addLine(to: CGPoint(x: 5, y: 0))
            path.addLine(to: CGPoint(x: 19, y: -3))
            path.addLine(to: CGPoint(x: 20, y: -3))
        }
        path.addLine(to: CGPoint(x: 20, y: rect.maxY))
        path.addLine(to: CGPoint(x: 19, y: rect.maxY))
        path.addLine(to: CGPoint(x: 5, y: rect.maxY - 3))
        path.addLine(to: CGPoint(x: 3, y: rect.maxY - 3))
        path.closeSubpath()
        return path
    }
}

private struct GameVerticalTabBar_SelectedTabEdges: Shape {
    var isFirst: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isFirst {
            path.move(to: CGPoint(x: 3.5, y: 0))
        } else {
            path.move(to: CGPoint(x: 19, y: -3.5))
            path.addLine(to: CGPoint(x: 5, y: -0.5))
            path.addLine(to: CGPoint(x: 3.5, y: -0.5))
        }
        path.addLine(to: CGPoint(x: 3.5, y: rect.maxY - 3.5))
        path.addLine(to: CGPoint(x: 5, y: rect.maxY - 3.5))
        path.addLine(to: CGPoint(x: 19, y: rect.maxY - 0.5))
        return path
    }
}

#Preview {
    @Previewable @State var selectedTab = "item"

    GameVerticalTabBar(tabs: ["item", "equip", "etc"], selection: $selectedTab) { tab in
        Text(verbatim: tab)
    }
    .padding(.bottom, 4)
    .background {
        GameStripeView()
    }
    .padding()
}
