//
//  SkillRowView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/2/11.
//

import RagnarokConstants
import SwiftUI

struct SkillRowView: View {
    var skillNode: SkillNode
    var currentLevel: Int
    var levelTemplate: String
    var isIncrementEnabled: Bool
    var isDecrementEnabled: Bool
    var inlineError: String?
    var lockReason: SkillLockReason?
    var onIncrement: () -> Void
    var onDecrement: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(skillNode.displayName)

                Spacer()

                Button {
                    onDecrement()
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .buttonStyle(.plain)
                .disabled(!isDecrementEnabled)

                ZStack {
                    Text(levelTemplate)
                        .hidden()
                    Text(verbatim: "\(currentLevel) / \(skillNode.maxLevel)")
                }
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)

                Button {
                    onIncrement()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.plain)
                .disabled(!isIncrementEnabled)
            }

            if let inlineError {
                Text(inlineError)
                    .font(.footnote)
                    .foregroundStyle(.red)
            } else if let lockReason, currentLevel == 0 {
                Text(lockReason.description)
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SkillRowView(
        skillNode: SkillNode(
            aegisName: "MG_NAPALMBEAT",
            displayName: "Napalm Beat",
            maxLevel: 10,
            requiredBaseLevel: 0,
            requiredJobLevel: 0,
            prerequisites: [],
            source: .direct(jobID: .swordman, jobName: "Swordman")
        ),
        currentLevel: 5,
        levelTemplate: "00 / 00",
        isIncrementEnabled: true,
        isDecrementEnabled: true,
        inlineError: nil,
        lockReason: nil,
        onIncrement: {},
        onDecrement: {}
    )
    .padding()
}
