//
//  GameSymbol.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/17.
//

import SwiftUI

enum GameSymbol: Shape {
    case minus
    case plus

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: 0.5, dy: 0.5)
        let (x0, x1, x2, x3) = (rect.minX, rect.midX - 1.5, rect.midX + 1.5, rect.maxX)
        let (y0, y1, y2, y3) = (rect.minY, rect.midY - 1.5, rect.midY + 1.5, rect.maxY)

        switch self {
        case .minus:
            return Path(CGRect(x: x0, y: y1, width: x3 - x0, height: y2 - y1))
        case .plus:
            var path = Path()
            path.move(to: CGPoint(x: x1, y: y0))
            path.addLine(to: CGPoint(x: x2, y: y0))
            path.addLine(to: CGPoint(x: x2, y: y1))
            path.addLine(to: CGPoint(x: x3, y: y1))
            path.addLine(to: CGPoint(x: x3, y: y2))
            path.addLine(to: CGPoint(x: x2, y: y2))
            path.addLine(to: CGPoint(x: x2, y: y3))
            path.addLine(to: CGPoint(x: x1, y: y3))
            path.addLine(to: CGPoint(x: x1, y: y2))
            path.addLine(to: CGPoint(x: x0, y: y2))
            path.addLine(to: CGPoint(x: x0, y: y1))
            path.addLine(to: CGPoint(x: x1, y: y1))
            path.closeSubpath()
            return path
        }
    }
}

struct GameSymbolView: View {
    var symbol: GameSymbol
    var isPressed: Bool

    var body: some View {
        let fill = isPressed ? Color(#colorLiteral(red: 0.4313725490, green: 0.5176470588, blue: 0.7764705882, alpha: 1)) : Color(#colorLiteral(red: 0.4549019608, green: 0.5490196078, blue: 0.8196078431, alpha: 1))
        let outline = isPressed ? Color(#colorLiteral(red: 0.4274509804, green: 0.4588235294, blue: 0.5607843137, alpha: 1)) : Color(#colorLiteral(red: 0.4509803922, green: 0.4862745098, blue: 0.5921568627, alpha: 1))

        ZStack {
            symbol
                .fill(fill)
            symbol
                .stroke(outline, lineWidth: 1)
        }
        .frame(width: 9, height: 9)
    }
}

#Preview {
    HStack(spacing: 12) {
        GameSymbolView(symbol: .minus, isPressed: false)
        GameSymbolView(symbol: .plus, isPressed: false)
    }
    .padding()
}
