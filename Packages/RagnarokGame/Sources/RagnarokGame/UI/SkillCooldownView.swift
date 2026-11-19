//
//  SkillCooldownView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/14.
//

import QuartzCore
import RagnarokModels
import SwiftUI

struct SkillCooldownView: View {
    var cooldown: SkillCooldown

    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                TimelineView(.animation) { _ in
                    let currentTime = CACurrentMediaTime()
                    let remainingTime = cooldown.duration > 0 ? (cooldown.endTime - currentTime) / cooldown.duration : 0
                    if remainingTime > 0 {
                        GameClockSector(startFraction: 1 - min(remainingTime, 1), endFraction: 1)
                            .fill(Color.black.opacity(0.75))
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .task(id: cooldown.endTime) {
            let currentTime = CACurrentMediaTime()
            let remainingTime = cooldown.endTime - currentTime
            guard remainingTime > 0 else {
                isActive = false
                return
            }
            isActive = true
            try? await Task.sleep(for: .seconds(remainingTime))
            if !Task.isCancelled {
                isActive = false
            }
        }
    }
}

#Preview {
    let currentTime = CACurrentMediaTime()
    let cooldown = SkillCooldown(skillID: 5, startTime: currentTime, duration: 10)

    ShortcutIconView(shortcut: .skill(skillID: 5, level: 10))
        .frame(width: 24, height: 24)
        .overlay {
            SkillCooldownView(cooldown: cooldown)
        }
        .padding()
        .environment(GameContext.testing)
}
