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
    case triangle

    nonisolated func path(in rect: CGRect) -> Path {
        switch self {
        case .minus:
            let thickness = min(rect.width, rect.height) / 3
            return Path(CGRect(x: rect.minX, y: rect.midY - thickness / 2, width: rect.width, height: thickness))
        case .plus:
            let thickness = min(rect.width, rect.height) / 3
            let (x0, x1, x2, x3) = (rect.minX, rect.midX - thickness / 2, rect.midX + thickness / 2, rect.maxX)
            let (y0, y1, y2, y3) = (rect.minY, rect.midY - thickness / 2, rect.midY + thickness / 2, rect.maxY)
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
        case .triangle:
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        Group {
            GameSymbol.minus
            GameSymbol.plus
            GameSymbol.triangle
        }
        .frame(width: 24, height: 24)
    }
    .padding()
}
