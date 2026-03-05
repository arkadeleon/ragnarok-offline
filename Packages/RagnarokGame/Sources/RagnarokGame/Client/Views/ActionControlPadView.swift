//
//  ActionControlPadView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/4.
//

import SGLMath
import SwiftUI

struct ActionControlPadView: View {
    var onAttack: () -> Void
    var onPickup: () -> Void
    var onTalk: () -> Void
    var onSkill: (Int) -> Void

    var body: some View {
        ZStack {
            RoundActionButton(
                title: "A",
                color: .red,
                diameter: 55,
                font: .title,
                action: onAttack
            )

            ForEach(0..<5, id: \.self) { index in
                RoundActionButton(
                    title: "S\(index + 1)",
                    color: .orange,
                    diameter: 45,
                    font: .headline
                ) {
                    onSkill(index)
                }
                .offset(
                    x: -75 * sin(radians(135 - CGFloat(index) * 45)),
                    y: -75 * cos(radians(135 - CGFloat(index) * 45))
                )
            }

            RoundActionButton(
                title: "P",
                color: .green,
                diameter: 35,
                font: .subheadline,
                action: onPickup
            )
            .offset(x: -65 * sin(radians(-110)), y: -65 * cos(radians(-110)))

            RoundActionButton(
                title: "T",
                color: .blue,
                diameter: 35,
                font: .subheadline,
                action: onTalk
            )
            .offset(x: -65 * sin(radians(-160)), y: -65 * cos(radians(-160)))
        }
        .frame(width: 180, height: 180)
        .offset(x: 10, y: 10)
    }

    init(
        onAttack: @escaping () -> Void,
        onPickup: @escaping () -> Void,
        onTalk: @escaping () -> Void,
        onSkill: @escaping (Int) -> Void = { _ in }
    ) {
        self.onAttack = onAttack
        self.onPickup = onPickup
        self.onTalk = onTalk
        self.onSkill = onSkill
    }
}

struct RoundActionButton: View {
    var title: String
    var color: Color
    var diameter: CGFloat
    var font: Font
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.75))
                    .frame(width: diameter, height: diameter)
                    .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 2)

                Text(title)
                    .font(font.bold())
                    .foregroundStyle(.white)
            }
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color.black.opacity(0.2)

        ActionControlPadView(onAttack: {}, onPickup: {}, onTalk: {})
            .border(Color.red)
            .padding(.bottom, 16)
            .padding(.trailing, 16)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
}
