//
//  GameSwordIcon.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/19.
//

import SwiftUI

struct GameSwordIcon: View {
    var body: some View {
        Canvas { context, size in
            let designBounds = CGRect(x: 6.4, y: 7.4, width: 17.6, height: 16.6)
            let scale = min(size.width / designBounds.width, size.height / designBounds.height)
            context.translateBy(
                x: size.width / 2 - designBounds.midX * scale,
                y: size.height / 2 - designBounds.midY * scale
            )
            context.scaleBy(x: scale, y: scale)

            let outline = GraphicsContext.Shading.color(Color(#colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.1098039216, alpha: 1)))
            let outlineStyle = StrokeStyle(lineWidth: 0.68, lineJoin: .round)

            let blade = Path { path in
                path.move(to: CGPoint(x: 7.0, y: 8.0))
                path.addLine(to: CGPoint(x: 12.6, y: 8.0))
                path.addLine(to: CGPoint(x: 20.4, y: 17.3))
                path.addLine(to: CGPoint(x: 17.3, y: 20.4))
                path.addLine(to: CGPoint(x: 7.0, y: 14.0))
                path.closeSubpath()
            }
            context.fill(
                blade,
                with: .color(Color(#colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.9411764706, alpha: 1)))
            )
            context.stroke(blade, with: outline, style: outlineStyle)

            let grip = Path { path in
                path.move(to: CGPoint(x: 20.2, y: 18.8))
                path.addLine(to: CGPoint(x: 23.4, y: 22.0))
                path.addLine(to: CGPoint(x: 22.0, y: 23.4))
                path.addLine(to: CGPoint(x: 18.8, y: 20.2))
                path.closeSubpath()
            }
            context.fill(
                grip,
                with: .color(Color(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.862745098, alpha: 1)))
            )
            context.stroke(grip, with: outline, style: outlineStyle)

            let swordGuard = Path { path in
                path.move(to: CGPoint(x: 21.4, y: 16.6))
                path.addQuadCurve(to: CGPoint(x: 17.0, y: 21.0), control: CGPoint(x: 18.6, y: 17.4))
                path.addQuadCurve(to: CGPoint(x: 21.4, y: 16.6), control: CGPoint(x: 20.4, y: 20.0))
                path.closeSubpath()
            }
            context.fill(swordGuard, with: .color(.white))
            context.stroke(swordGuard, with: outline, style: outlineStyle)
        }
    }
}

#Preview {
    GameSwordIcon()
        .frame(width: 40, height: 40)
}
