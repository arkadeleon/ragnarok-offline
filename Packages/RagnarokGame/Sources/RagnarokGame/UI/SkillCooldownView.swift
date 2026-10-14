//
//  SkillCooldownView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/14.
//

import RagnarokModels
import SwiftUI

struct SkillCooldownView: View {
    var cooldown: SkillCooldown

    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                TimelineView(.animation) { _ in
                    Canvas { context, size in
                        let remaining = ContinuousClock.now.duration(to: cooldown.endTime) / cooldown.duration
                        guard remaining > 0 else {
                            return
                        }

                        // The radius reaches the corners, so the sector covers the whole square.
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radius = hypot(size.width, size.height) / 2
                        let startAngle = Angle.degrees(-90 + (1 - min(remaining, 1)) * 360)

                        var path = Path()
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: .degrees(270), clockwise: false)
                        path.closeSubpath()

                        context.fill(path, with: .color(.black.opacity(0.75)))
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .task(id: cooldown.endTime) {
            isActive = ContinuousClock.now < cooldown.endTime
            try? await Task.sleep(until: cooldown.endTime, clock: .continuous)
            if !Task.isCancelled {
                isActive = false
            }
        }
    }
}

#Preview {
    let cooldown = SkillCooldown(skillID: 5, startTime: .now, duration: .seconds(10))

    ShortcutIconView(shortcut: .skill(skillID: 5, level: 10))
        .frame(width: 24, height: 24)
        .overlay {
            SkillCooldownView(cooldown: cooldown)
        }
        .padding()
        .environment(GameContext.testing)
}
