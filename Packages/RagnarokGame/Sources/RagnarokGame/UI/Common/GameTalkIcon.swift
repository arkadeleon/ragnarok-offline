//
//  GameTalkIcon.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/13.
//

import SwiftUI

struct GameTalkIcon: View {
    var body: some View {
        Canvas { context, size in
            let designBounds = CGRect(x: 0, y: 0, width: 62, height: 46)
            let scale = min(size.width / designBounds.width, size.height / designBounds.height)
            context.translateBy(
                x: size.width / 2 - designBounds.midX * scale,
                y: size.height / 2 - designBounds.midY * scale
            )
            context.scaleBy(x: scale, y: scale)

            let outline = GraphicsContext.Shading.color(Color(#colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.1098039216, alpha: 1)))
            let outlineStyle = StrokeStyle(lineWidth: 4, lineJoin: .round)

            let balloon = Path(ellipseIn: CGRect(x: 2, y: 2, width: 58, height: 32))
            let tail = Path { path in
                path.move(to: CGPoint(x: 29, y: 29))
                path.addLine(to: CGPoint(x: 42, y: 29))
                path.addLine(to: CGPoint(x: 24, y: 43))
                path.closeSubpath()
            }
            context.stroke(balloon, with: outline, style: outlineStyle)
            context.stroke(tail, with: outline, style: outlineStyle)

            context.fill(
                balloon,
                with: .color(Color(#colorLiteral(red: 0.8235294118, green: 0.8156862745, blue: 0.8980392157, alpha: 1)))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: 3, y: 3, width: 55, height: 30)),
                with: .color(Color(#colorLiteral(red: 0.968627451, green: 0.968627451, blue: 1, alpha: 1)))
            )
            context.fill(
                tail,
                with: .color(Color(#colorLiteral(red: 0.968627451, green: 0.968627451, blue: 1, alpha: 1)))
            )

            for centerX in [17.0, 31, 45] {
                context.fill(
                    Path(ellipseIn: CGRect(x: centerX - 5.5, y: 13.5, width: 11, height: 11)),
                    with: .color(Color(#colorLiteral(red: 0.431372549, green: 0.4078431373, blue: 0.5098039216, alpha: 1)))
                )
            }
        }
    }
}

#Preview {
    GameTalkIcon()
        .frame(width: 40, height: 40)
        .padding()
}
