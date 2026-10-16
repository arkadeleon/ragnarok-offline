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
                    let remaining = ContinuousClock.now.duration(to: cooldown.endTime) / cooldown.duration
                    if remaining > 0 {
                        GameClockSector(startFraction: 1 - min(remaining, 1), endFraction: 1)
                            .fill(Color.black.opacity(0.75))
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
