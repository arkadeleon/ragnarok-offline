//
//  GameRingSector.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/19.
//

import SwiftUI

/// The area between two radii, spanning `sweepAngle` around `centerAngle`.
struct GameRingSector: Shape {
    var centerAngle: Angle
    var sweepAngle: Angle
    var innerRadius: CGFloat
    var outerRadius: CGFloat
    var gap: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let inset = gap / 2
        let halfSweepAngle = sweepAngle / 2

        let innerShift = Angle.radians(asin(inset / innerRadius))
        let outerShift = Angle.radians(asin(inset / outerRadius))

        var path = Path()
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: centerAngle - halfSweepAngle + outerShift,
            endAngle: centerAngle + halfSweepAngle - outerShift,
            clockwise: false
        )
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: centerAngle + halfSweepAngle - innerShift,
            endAngle: centerAngle - halfSweepAngle + innerShift,
            clockwise: true
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        ForEach(0..<8) { index in
            GameRingSector(
                centerAngle: .degrees(45 * Double(index)),
                sweepAngle: .degrees(45),
                innerRadius: 35,
                outerRadius: 80,
                gap: 4
            )
        }

    }
    .frame(width: 160, height: 160)
}
