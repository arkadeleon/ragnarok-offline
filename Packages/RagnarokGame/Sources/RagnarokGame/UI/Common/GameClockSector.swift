//
//  GameClockSector.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/16.
//

import SwiftUI

struct GameClockSector: Shape {
    var startFraction: Double
    var endFraction: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = hypot(rect.width, rect.height) / 2

        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(-90 + startFraction * 360),
            endAngle: .degrees(-90 + endFraction * 360),
            clockwise: false
        )
        path.closeSubpath()
        return path.intersection(Path(rect))
    }
}

#Preview {
    HStack {
        GameClockSector(startFraction: 0, endFraction: 0.3)
            .fill(.orange)
            .frame(width: 48, height: 48)
            .border(.gray)

        GameClockSector(startFraction: 0.3, endFraction: 1)
            .fill(.black.opacity(0.75))
            .frame(width: 48, height: 48)
            .border(.gray)
    }
    .padding()
}
